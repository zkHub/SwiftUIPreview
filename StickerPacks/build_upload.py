import csv
import os
import subprocess

# 获取当前工作目录
base_dir = os.getcwd()

# 读取 CSV 文件
with open('apps_config/apps.csv', newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        app_name = row['app_name']
        short_id = row['short_id']
        display_name = row['display_name']
        resource_folder = row['resource_folder']

        # 构建项目路径
        project_path = os.path.join(base_dir, "generated_apps", app_name)

        # 检查项目路径是否存在
        if not os.path.isdir(project_path):
            print(f"项目目录 {project_path} 不存在，跳过该应用。")
            continue

        # 切换到项目目录
        os.chdir(project_path)

        print(f"开始上传 {app_name}...")

        # 使用 subprocess.Popen 实时打印输出
        process = subprocess.Popen(
            ['fastlane', 'build_and_upload'],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )

        # 实时读取并打印输出
        for line in process.stdout:
            print(line, end='')

        process.wait()

        if process.returncode == 0:
            print(f"{app_name} 上传成功。")
        else:
            print(f"{app_name} 上传失败，返回码：{process.returncode}")

        # 返回上级目录
        os.chdir(base_dir)
