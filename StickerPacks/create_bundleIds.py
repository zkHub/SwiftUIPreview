import os, jwt, time, requests, openpyxl

# ——— 配置部分 —————————————————————————————
KEY_ID = "X22F658K7F"
ISSUER_ID = "69a6de77-92ab-47e3-e053-5b8c7c11a4d1"
PRIVATE_KEY = open("AuthKey_X22F658K7F.p8","r").read()
EXCEL_PATH = "apps_config/apps.xlsx"
BUNDLE_PREFIX = "com.getsticker.stickerpack."
# —————————————————————————————————————————

base_url = 'https://api.appstoreconnect.apple.com/v1'

def make_jwt():
    header = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now+600, "aud": "appstoreconnect-v1"}
    token = jwt.encode(payload, PRIVATE_KEY, algorithm="ES256", headers=header)
    return token.decode("utf-8") if isinstance(token, bytes) else token

jwt_token = make_jwt()
headers = { "Authorization": f"Bearer {jwt_token}", "Content-Type": "application/json"}

def exists_bundle(bundle, headers):
    r = requests.get("https://api.appstoreconnect.apple.com/v1/bundleIds",
                     headers=headers, params={"filter[identifier]": bundle})
    return bool(r.ok and r.json().get("data"))

def exists_app(bundle, headers):
    r = requests.get("https://api.appstoreconnect.apple.com/v1/apps",
                     headers=headers, params={"filter[bundleId]": bundle})
    return bool(r.ok and r.json().get("data"))

def create_bundle(bundle, name, headers):
    r = requests.post("https://api.appstoreconnect.apple.com/v1/bundleIds",
                      headers=headers,
                      json={"data":{"type":"bundleIds",
                                    "attributes":{"identifier":bundle,"name":name,"platform":"IOS"}}})
    return r.ok, r.json()

def create_app(bundle, name, headers):
    r = requests.post("https://api.appstoreconnect.apple.com/v1/apps",
                      headers=headers,
                      json={"data":{"type":"apps",
                                    "attributes":{"bundleId":bundle,"name":name,"sku":bundle,"primaryLocale":"en-US"}}})
    return r.ok, r.json()

# ————— 主流程 —————————————————————————————
wb = openpyxl.load_workbook(EXCEL_PATH)
ws = wb.active
cols = [cell.value for cell in next(ws.iter_rows(min_row=1, max_row=1))]
try:
    idx_short = cols.index("short_id")
    idx_name = cols.index("app_name")
except ValueError:
    raise RuntimeError("Excel must have columns 'short_id' and 'app_name'")

for row in ws.iter_rows(min_row=2, values_only=True):
    sid, nm = row[idx_short], row[idx_name]
    if not sid or not nm:
        print("⚠️ 跳过空行或缺字段：", row)
        continue
    short_id = str(sid).strip()
    name = str(nm).strip()
    bundle = BUNDLE_PREFIX + short_id
    print(f"\n📦 处理 {bundle} – '{name}'")

    if exists_bundle(bundle, headers):
        print("✅ Bundle 已存在，跳过创建")
    else:
        ok, resp = create_bundle(bundle, name, headers)
        print("Bundle 创建", "成功" if ok else "失败", resp)
        if not ok: continue

    if exists_app(bundle, headers):
        print("✅ App 已存在，跳过创建")
    else:
        ok2, resp2 = create_app(bundle, name, headers)
        print("App 创建", "成功" if ok2 else "失败", resp2)
