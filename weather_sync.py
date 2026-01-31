import requests
import json
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import threading
import time
import os
from urllib.parse import unquote

CRED_PATH = 'serviceAccountKey.json'
DB_URL = 'https://weatherlight-3e0ba-default-rtdb.firebaseio.com/'

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
    if not os.path.exists(CRED_PATH):
        raise FileNotFoundError(f"File not found: {CRED_PATH}")

    if not firebase_admin._apps:
        cred = credentials.Certificate(CRED_PATH)
        firebase_admin.initialize_app(cred, {'databaseURL': DB_URL})
        print("Firebase Auth Success")

def fetch_air_thread():
    global global_air_data
    print("Fetching Air Data...")
    
    if not AIR_KEY:
        return

    kst_now = datetime.utcnow() + timedelta(hours=9)
    today_date = kst_now.strftime("%Y-%m-%d")
    
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
            print(f"Air API Error: {res.status_code}")
            
    except Exception as e:
        print(f"Air Thread Error: {e}")

def fetch_weather_thread():
    global global_weather_data
    print("Fetching Weather Data...")
    
    if not WEATHER_KEY:
        return

    url = f'https://apihub.kma.go.kr/api/typ01/url/fct_afs_dl2.php?stn=108&tmfc=0&disp=0&help=1&authKey={WEATHER_KEY}'
    
    try:
        res = requests.get(url, timeout=15)
        # [수정됨] 기상청 텍스트 API는 euc-kr을 사용합니다. utf-8로 하면 깨집니다.
        res.encoding = 'euc-kr' 
        
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
                        global_weather_data[name] = {
                            'rain_prob': parts[14],
                            'condition': parts[17].replace('"', '')
                        }
    except Exception as e:
        print(f"Weather Thread Error: {e}")

if __name__ == "__main__":
    start_time = time.time()
    print("--- Weatherlight Server Start ---")

    try:
        init_firebase()
    except Exception as e:
        print(f"Init Error: {e}")
        exit(1)

    t1 = threading.Thread(target=fetch_air_thread)
    t2 = threading.Thread(target=fetch_weather_thread)
    
    t1.start()
    t2.start()
    
    t1.join()
    t2.join()
    
    kst_time = datetime.utcnow() + timedelta(hours=9)
    
    final_payload = {
        "last_updated": kst_time.strftime("%Y-%m-%d %H:%M:%S"),
        "regions": {}
    }

    print("Uploading to Firebase...")
    for region in TARGET_REGIONS:
        pm10 = global_air_data.get(region, "정보없음")
        w_info = global_weather_data.get(region, {'rain_prob': '0', 'condition': '정보없음'})
        
        final_payload["regions"][region] = {
            "pm10": pm10,
            "rain_prob": w_info['rain_prob'],
            "condition": w_info['condition']
        }

    try:
        db.reference('weather_data').set(final_payload)
        print("Upload Success")
    except Exception as e:
        print(f"Upload Failed: {e}")
        exit(1)