import jwt
import time
import requests
import pandas as pd

# 配置部分
KEY_ID = '9Q394F5TP7'  # 替换为你的Key ID
ISSUER_ID = '69a6de8b-552c-47e3-e053-5b8c7c11a4d1'  # 替换为你的Issuer ID
PRIVATE_KEY = open('AuthKey_9Q394F5TP7.p8', 'r').read()  # 认证文件路径
APP_ID = '1630343674'  # 你的应用ID
BASE_URL = 'https://api.appstoreconnect.apple.com/v1'
VERSIONS = ['1.550.12']

# 生成JWT认证令牌
def make_jwt():
    header = {'alg': 'ES256', 'kid': KEY_ID, 'typ': 'JWT'}
    payload = {
        'iss': ISSUER_ID,
        'aud': 'appstoreconnect-v1',
        'iat': int(time.time()),
        'exp': int(time.time()) + 1200  # 20分钟有效期
    }
    return jwt.encode(payload, PRIVATE_KEY, algorithm='ES256', headers=header)

# 获取所有版本ID及版本号
def get_app_versions(app_id):
    jwt_token = make_jwt()
    headers = {'Authorization': f'Bearer {jwt_token}'}
    versions = []
    next_url = f'{BASE_URL}/apps/{app_id}/appStoreVersions'
    
    while next_url:
        params = {
            'limit': 200
        }
        if VERSIONS:
            params['filter[versionString]'] = ''.join(VERSIONS)
        response = requests.get(next_url, headers=headers, params=params)
        if response.status_code == 401:  # Token刷新
            jwt_token = make_jwt()
            headers['Authorization'] = f'Bearer {jwt_token}'
            continue
        data = response.json()
        for item in data.get('data', []):
            version_id = item['id']
            version_num = item['attributes']['versionString']
            versions.append({'id': version_id, 'version': version_num})
        next_url = data.get('links', {}).get('next')
        time.sleep(1)  # 避免触发API速率限制（每分钟20次）
    return versions

# 按版本ID获取评论
def get_reviews_by_version(version_id):
    reviews = []
    next_url = f'{BASE_URL}/appStoreVersions/{version_id}/customerReviews?limit=200'
    jwt_token = make_jwt()
    headers = {'Authorization': f'Bearer {jwt_token}'}
    
    while next_url:
        response = requests.get(next_url, headers=headers)
        if response.status_code == 401:
            jwt_token = make_jwt()
            headers['Authorization'] = f'Bearer {jwt_token}'
            continue
        data = response.json()
        for review in data.get('data', []):
            attrs = review['attributes']
            reviews.append({
                'version_id': version_id,
                'rating': attrs['rating'],
                'title': attrs.get('title', ''),
                'content': attrs.get('body', ''),
                'user': attrs.get('reviewerNickname', ''),
                'date': attrs['createdDate'].split('T')[0],  # 仅保留日期
                'territory': attrs['territory']
            })
        next_url = data.get('links', {}).get('next')
        time.sleep(1)
    return reviews

# 主流程：整合版本与评论数据
def export_versioned_reviews():
    all_data = []
    versions = get_app_versions(APP_ID)
    print(f"共获取 {len(versions)} 个版本")
    
    for ver in versions:
        print(f"获取版本 {ver['version']} 的评论...")
        reviews = get_reviews_by_version(ver['id'])
        for rev in reviews:
            rev['app_version'] = ver['version']  # 添加版本号字段
        all_data.extend(reviews)
    
    # 导出Excel
    if all_data:
        df = pd.DataFrame(all_data)
        df = df[['app_version', 'rating', 'title', 'content', 'user', 'date', 'territory']]  # 调整列顺序
        df.to_excel('versioned_reviews.xlsx', index=False)
        print(f"导出成功！共 {len(df)} 条评论")

# 执行
if __name__ == '__main__':
    export_versioned_reviews()
