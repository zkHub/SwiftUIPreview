import os
import csv
import subprocess

# 配置文件路径
CONFIG_FILE = 'apps_config/apps.csv'

def create_bundle_ids():
    with open(CONFIG_FILE, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            short_id = row['short_id'].strip()
            app_name = row['app_name'].strip()
            bundle_id = f"com.getsticker.stickerpack.{short_id}"

            print(f"🔧 正在创建 Bundle ID: {bundle_id}")

            try:
                subprocess.run([
                    "fastlane", "produce",
                    "--app_identifier", bundle_id,
                    "--app_name", app_name,
                    "--sku", f"SKU_{short_id}",
                    "--language", "English"
                ], check=True)
                print(f"✅ 成功创建: {bundle_id}")
            except subprocess.CalledProcessError as e:
                error_output = e.stderr.decode() if e.stderr else str(e)
                if "already exists" in error_output:
                    print(f"⚠️  Bundle ID 已存在，跳过：{bundle_id}")
                else:
                    print(f"❌ 创建失败：{bundle_id}，错误信息：{error_output}")

if __name__ == '__main__':
    create_bundle_ids()
