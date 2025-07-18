import os, jwt, time, requests, openpyxl
import shutil, re, json, plistlib
from PIL import Image
import subprocess


# ——— 配置部分 —————————————————————————————
KEY_ID = 'X22F658K7F'
ISSUER_ID = '69a6de77-92ab-47e3-e053-5b8c7c11a4d1'
PRIVATE_KEY = open('AuthKey_X22F658K7F.p8','r').read()
BUNDLE_PREFIX = 'com.getsticker.stickerpack.'
# —————————————————————————————————————————

base_url = 'https://api.appstoreconnect.apple.com/v1'
short_id = os.environ['BUNDLE_ID']
app_name = os.environ['APP_NAME']
version = os.environ['VERSION']
resource_folder = os.environ['RESOURCE']
bundle_id = BUNDLE_PREFIX + short_id

def make_jwt():
    header = {'alg': 'ES256', 'kid': KEY_ID, 'typ': 'JWT'}
    now = int(time.time())
    payload = {'iss': ISSUER_ID, 'iat': now, 'exp': now+600, 'aud': 'appstoreconnect-v1'}
    token = jwt.encode(payload, PRIVATE_KEY, algorithm='ES256', headers=header)
    return token.decode('utf-8') if isinstance(token, bytes) else token

jwt_token = make_jwt()
headers = { 'Authorization': f'Bearer {jwt_token}', 'Content-Type': 'application/json'}

def exists_bundle(bundle):
    r = requests.get(f'{base_url}/bundleIds',
                     headers=headers, params={'filter[identifier]': bundle})
    return bool(r.ok and r.json().get('data'))

def exists_app(bundle):
    r = requests.get(f'{base_url}/apps',
                     headers=headers, params={'filter[bundleId]': bundle})
    return bool(r.ok and r.json().get('data'))

def create_bundle(bundle, name):
    r = requests.post(f'{base_url}/bundleIds',
                      headers=headers,
                      json={'data':{'type':'bundleIds',
                                    'attributes':{'identifier':bundle,'name':name,'platform':'IOS'}}})
    return r.ok, r.json()

def create_app(bundle, name):
    r = requests.post(f'{base_url}/apps',
                      headers=headers,
                      json={'data':{'type':'apps',
                                    'attributes':{'bundleId':bundle,'name':name,'sku':bundle,'primaryLocale':'en-US'}}})
    return r.ok, r.json()

# ————— 主流程 —————————————————————————————

# ————— AppStore 创建App —————————————————————————————

if exists_bundle(bundle_id):
    print('✅ Bundle 已存在，跳过创建')
else:
    ok, resp = create_bundle(bundle_id, app_name)
    print('Bundle 创建', '成功' if ok else '失败', resp)
    if not ok:
        print('Bundle id 创建失败', resp)
        sys.exit(1)
    else:
        print('Bundle id 创建成功', resp)


if exists_app(bundle_id):
    print('✅ App 已存在，跳过创建')
else:
    ok2, resp2 = create_app(bundle_id, app_name)
    print('App 创建', '成功' if ok2 else '失败', resp2)
    if not ok2:
        print('App 创建失败', resp2)
        sys.exit(1)
    else:
        print('Bundle id 创建成功', resp)


# ————— 根据模版生成App —————————————————————————————

# 模板项目根目录
TEMPLATE_DIR = 'template'

# 输出工程目录
OUTPUT_DIR = 'generated_apps'

# 所有资源文件的根路径
BASE_CONFIG_DIR = 'apps_config'

# ======================
# 工具函数：生成等比例图标
# ======================
def make_image_canvas_fit(image, target_size):
    """将图片等比例缩放到指定尺寸，并居中填充到透明背景中"""
    src_ratio = image.width / image.height
    tgt_width, tgt_height = target_size
    tgt_ratio = tgt_width / tgt_height

    if src_ratio > tgt_ratio:
        new_width = tgt_width
        new_height = int(tgt_width / src_ratio)
    else:
        new_height = tgt_height
        new_width = int(tgt_height * src_ratio)

    resized = image.resize((new_width, new_height), Image.LANCZOS)
    canvas = Image.new("RGBA", (tgt_width, tgt_height), (0, 0, 0, 0))  # 透明背景
    canvas.paste(resized, ((tgt_width - new_width) // 2, (tgt_height - new_height) // 2))
    return canvas

# ============================
# 图标处理：从1024生成所有尺寸
# ============================
def generate_resized_icons(source_icon_path, iconset_path):
    """读取 Contents.json 需求，生成多尺寸 icon 图"""
    contents_json_path = os.path.join(iconset_path, "Contents.json")
    with open(contents_json_path, "r") as f:
        contents = json.load(f)

    base_image = Image.open(source_icon_path).convert("RGBA")

    for item in contents.get("images", []):
        filename = item.get("filename")
        size_str = item.get("size")
        scale_str = item.get("scale")
        if not filename or not size_str or not scale_str:
            continue

        scale = int(scale_str.replace("x", ""))
        w_pt, h_pt = map(float, size_str.split("x"))
        w_px, h_px = int(w_pt * scale), int(h_pt * scale)

        resized_img = make_image_canvas_fit(base_image, (w_px, h_px))
        # 创建白色背景
        background = Image.new("RGB", resized_img.size, (255, 255, 255))
        # 将带有透明通道的图像粘贴到白色背景上，使用 alpha 通道作为掩码
        background.paste(resized_img, mask=resized_img.split()[3])  # 使用 alpha 通道作为掩码

        # 保存为不包含透明通道的 PNG
        background.save(os.path.join(iconset_path, filename), format="PNG")

    print(f"🎨 已生成 {len(contents['images'])} 个 icon 尺寸")

# ============================
# 替换图标资源
# ============================
def replace_icons(extension_path, resource_path):
    source_icon = os.path.join(resource_path, "icon-1024.png")
    iconset_path = os.path.join(extension_path, "Stickers.xcstickers", "iMessage App Icon.stickersiconset")

    # 删除旧 icon PNG 文件（保留 Contents.json）
    for f in os.listdir(iconset_path):
        if f.lower().endswith(".png"):
            os.remove(os.path.join(iconset_path, f))

    generate_resized_icons(source_icon, iconset_path)

# ============================
# 替换贴纸资源
# ============================
def replace_stickers(extension_path, resource_path):
    source_sticker_path = os.path.join(resource_path, "stickers")
    target_sticker_root = os.path.join(
        extension_path,
        "Stickers.xcstickers",
        "Sticker Pack.stickerpack"
    )

    # 清空旧资源
    for item in os.listdir(target_sticker_root):
        full = os.path.join(target_sticker_root, item)
        if os.path.isfile(full):
            os.remove(full)
        elif os.path.isdir(full):
            shutil.rmtree(full)

    stickers_list = []

    for file in os.listdir(source_sticker_path):
        if not file.lower().endswith(".png"):
            continue
        name = os.path.splitext(file)[0]
        sticker_folder = f"{name}.sticker"
        dest_folder = os.path.join(target_sticker_root, sticker_folder)
        os.makedirs(dest_folder, exist_ok=True)

        # 拷贝 PNG 并生成该 .sticker 的 Contents.json
        shutil.copy(os.path.join(source_sticker_path, file), os.path.join(dest_folder, file))
        child_contents = {
            "info": {"version": 1, "author": "xcode"},
            "properties": {"filename": file}
        }
        with open(os.path.join(dest_folder, "Contents.json"), "w") as f:
            json.dump(child_contents, f, indent=2)

        stickers_list.append({"filename": sticker_folder})

    # 根目录的 Contents.json
    main_contents = {
        "info": {"version": 1, "author": "xcode"},
        "properties": {"grid-size": "regular"},
        "stickers": stickers_list
    }
    with open(os.path.join(target_sticker_root, "Contents.json"), "w") as f:
        json.dump(main_contents, f, indent=2)

    print(f"🧩 已添加 {len(stickers_list)} 个 sticker 文件")

# ============================
# 修改 Info.plist
# ============================
def modify_info_plist(plist_path, display_name):
    with open(plist_path, 'rb') as f:
        plist = plistlib.load(f)
    plist['CFBundleDisplayName'] = display_name
    with open(plist_path, 'wb') as f:
        plistlib.dump(plist, f)

# ============================
# 修改 project.pbxproj 中的 Bundle ID 和 MARKETING_VERSION
# ============================
def replace_bundle_id_in_pbxproj(pbxproj_path, bundle_id, ext_bundle_id, version):
    with open(pbxproj_path, "r", encoding="utf-8") as f:
        contents = f.read()

    updated_contents = contents.replace("com.getsticker.stickerpack.template", bundle_id)
    updated_contents = updated_contents.replace("com.getsticker.stickerpack.template.StickerPackExtension", ext_bundle_id)
    print(f"✅ 替换完成：{bundle_id} {ext_bundle_id}")

    # 使用正则表达式替换 MARKETING_VERSION 的值
    new_content = re.sub(r'MARKETING_VERSION = [^;]+;', f'MARKETING_VERSION = {version};', updated_contents)
    print(f"✅ 已将 MARKETING_VERSION 更新为 {version}")

    with open(pbxproj_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"✅ 替换完成")

# ============================
# 拷贝模板工程
# ============================
def copy_template(app_name):
    target_path = os.path.join(OUTPUT_DIR, app_name)
    if os.path.exists(target_path):
        shutil.rmtree(target_path)
    shutil.copytree(TEMPLATE_DIR, target_path)
    return target_path

# ============================
# 构建单个 App 工程
# ============================
def process_app():
    print(f'🎯 正在生成 {app_name}')
    # extension_bundle_id
    extension_bundle_id = f'{bundle_id}.StickerPackExtension'

    target = copy_template(app_name)

    # 修改 Info.plist
    main_plist_path = os.path.join(target, 'template', 'Info.plist')
    extension_plist_path = os.path.join(target, 'template StickerPackExtension', 'Info.plist')
    modify_info_plist(main_plist_path, app_name)
    modify_info_plist(extension_plist_path, app_name)

    # 修改 .xcodeproj 的 bundle id
    pbxproj_path = os.path.join(target, f'{os.path.basename(TEMPLATE_DIR)}.xcodeproj', 'project.pbxproj')
    replace_bundle_id_in_pbxproj(pbxproj_path, bundle_id, extension_bundle_id, version)

    # 替换贴纸与图标资源
    extension_path = os.path.join(target, 'template StickerPackExtension')
    resource_path = os.path.join(BASE_CONFIG_DIR, resource_folder)
    replace_icons(extension_path, resource_path)
    replace_stickers(extension_path, resource_path)
    print(f'✅ StickerPackApp 生成完成')

process_app()


## ————— 打包上传App —————————————————————————————
#
#def build_upload():
#    # 获取当前工作目录
#    base_dir = os.getcwd()
#    # 构建项目路径
#    project_path = os.path.join(base_dir, "generated_apps", app_name)
#    # 检查项目路径是否存在
#    if not os.path.isdir(project_path):
#        print(f'项目目录 {project_path} 不存在')
#        sys.exit(1)
#    # 切换到项目目录
#    os.chdir(project_path)
#    print(f'开始上传 {app_name}...')
#    
#    # 使用 subprocess.Popen 实时打印输出
#    process = subprocess.Popen(
#        ['fastlane', 'build_and_upload'],
#        stdout=subprocess.PIPE,
#        stderr=subprocess.STDOUT,
#        text=True
#    )
#
#    # 实时读取并打印输出
#    for line in process.stdout:
#        print(line, end='')
#
#    process.wait()
#
#    if process.returncode == 0:
#        print(f'✅ {app_name} 上传成功')
#    else:
#        print(f'❎{app_name} 上传失败，返回码：{process.returncode}')
#        sys.exit(1)
#    # 返回上级目录
#    os.chdir(base_dir)
#
#
#build_upload()
