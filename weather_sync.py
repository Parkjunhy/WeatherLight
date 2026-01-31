import requests
import json
from datetime import datetime
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import threading
import time
import os
from urllib.parse import unquote  # [추가] 키 디코딩용 모듈

# --- 설정 ---
CRED_PATH = 'serviceAccountKey.json'
DB_URL = 'https://weatherlight-3e0ba-default-rtdb.firebaseio.com/'

# [중요] GitHub Secrets에서 가져올 때, 공공데이터 포털 키가 꼬이는 걸 방지하기 위해 unquote 사용
# (환경변수가 없으면 None 대신 빈 문자열 '' 반환하여 에러 방지)
AIR_KEY = unquote(os.environ.get("AIR_KEY", ""))
WEATHER_KEY = unquote(os.environ.get("WEATHER_KEY", ""))

TARGET_REGIONS = ['서울', '인천', '강원', '충북', '충남', '경북', '경남', '전북', '전남']

WEATHER_STATION_CODES = {
    '서울': '11B10101', '인천': '11B20201', '강원': '11D20501',
    '충북': '11C10301', '충남': '11C20401', '경북': '11H10701',
    '경남': '11H20201', '전북': '11F10201', '전남': '11F20501'
}

global_air_data = {}
global_weather_data = {}

def init_firebase():
    # [추가] 파일이 실제로 존재하는지 먼저 확인
    if not os.path.exists(CRED_PATH):
        raise FileNotFoundError(f"❌ {CRED_PATH} 파일을 찾을 수 없습니다. GitHub Actions 설정(YAML)을 확인하세요.")

    if not firebase_admin._apps:
        cred = credentials.Certificate(CRED_PATH)
        firebase_admin.initialize_app(cred, {'databaseURL': DB_URL})
        print("🔥 Firebase 인증 완료")

def fetch_air_thread():
    global global_air_data
    print("   [Thread-1] 🏭 미세먼지 조회 시작...")
    
    if not AIR_KEY:
        print("   [Thread-1] ⚠️ AIR_KEY가 없습니다. 조회를 건너뜁니다.")
        return

    today_date = datetime.now().strftime("%Y-%m-%d")
    url = 'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMinuDustFrcstDspth'
    params = {
        'serviceKey': AIR_KEY, 
        'returnType': 'json', 
        'numOfRows': '100',
        'pageNo': '1', 
        'searchDate': today_date, 
        'InformCode': 'PM10'
    }
    
    try:
        res = requests.get(url, params=params, timeout=10)
        if res.status_code == 200:
            # 공공데이터포털 JSON 구조가 가끔 다를 수 있어 안전하게 처리
            data = res.json()
            items = data.get('response', {}).get('body', {}).get('items')
            
            if items:
                raw_grades = items[0]['informGrade']
                for item in raw_grades.split(','):
                    if ':' in item:
                        r, g = item.split(':')
                        region = r.strip()
                        if region == '영동': global_air_data['강원'] = g.strip()
                        elif region in TARGET_REGIONS: global_air_data[region] = g.strip()
            else:
                print("   [Thread-1] 데이터 없음 (items is empty)")
        else:
            print(f"   [Thread-1] 응답 코드 에러: {res.status_code}")
            
    except Exception as e:
        print(f"   [Thread-1] ⚠️ 에러 발생: {e}")
    print("   [Thread-1] ✅ 미세먼지 로직 종료")

def fetch_weather_thread():
    global global_weather_data
    print("   [Thread-2] 🌦️ 날씨 조회 시작...")
    
    if not WEATHER_KEY:
        print("   [Thread-2] ⚠️ WEATHER_KEY가 없습니다. 조회를 건너뜁니다.")
        return

    # 기상청 API는 URL에 키가 포함되는 방식이라 params 대신 f-string 사용
    url = f'https://apihub.kma.go.kr/api/typ01/url/fct_afs_dl2.php?stn=108&tmfc=0&disp=0&help=1&authKey={WEATHER_KEY}'
    
    try:
        res = requests.get(url, timeout=15)
        # 텍스트 응답이므로 인코딩 강제 설정 (한글 깨짐 방지)
        res.encoding = 'utf-8' 
        
        lines = res.text.split('\n')
        code_to_name = {v: k for k, v in WEATHER_STATION_CODES.items()}
        
        for line in lines:
            if line.startswith('#') or not line.strip(): continue
            parts = line.split()
            if len(parts) >= 18:
                reg_id = parts[0]
                if reg_id in code_to_name:
                    name = code_to_name[reg_id]
                    if name not in global_weather_data:
                        # 데이터가 있으면 저장
                        global_weather_data[name] = {
                            'rain_prob': parts[14],
                            'condition': parts[17].replace('"', '')
                        }
    except Exception as e:
        print(f"   [Thread-2] ⚠️ 에러 발생: {e}")
    print("   [Thread-2] ✅ 날씨 로직 종료")

if __name__ == "__main__":
    start_time = time.time()
    print("--- 🚀 Weatherlight Fast Server (GitHub Actions Ver.) ---")

    # 1. Firebase 인증 시도
    try:
        init_firebase()
    except Exception as e:
        print(f"❌ 초기화 실패: {e}")
        exit(1) # 에러나면 GitHub Actions가 실패로 표시되게 강제 종료

    # 2. 스레드 시작
    t1 = threading.Thread(target=fetch_air_thread)
    t2 = threading.Thread(target=fetch_weather_thread)
    
    t1.start()
    t2.start()
    
    t1.join()
    t2.join()
    
    print(f"\n⏱️ 데이터 수집 소요 시간: {time.time() - start_time:.2f}초")

    # 3. 데이터 취합 및 업로드
    final_payload = {
        "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "regions": {}
    }

    print("📡 Firebase 업로드 준비...")
    for region in TARGET_REGIONS:
        # 데이터가 없으면 기본값 처리
        pm10 = global_air_data.get(region, "정보없음")
        w_info = global_weather_data.get(region, {'rain_prob': '0', 'condition': '정보없음'})
        
        final_payload["regions"][region] = {
            "pm10": pm10,
            "rain_prob": w_info['rain_prob'],
            "condition": w_info['condition']
        }

    try:
        # 루트 노드 업데이트
        db.reference('weather_data').set(final_payload)
        print("✅ Firebase 전송 완료! (Success)")
    except Exception as e:
        print(f"❌ Firebase 전송 실패: {e}")
        exit(1)