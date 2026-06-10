#!/usr/bin/env python3
"""sing-box TUI: 交互式节点选择与切换"""

import json
import os
import subprocess
import sys
from urllib.parse import urlparse, parse_qs, unquote

import questionary

CONFIG_DIR = os.path.expanduser("~/.sing-box")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")
LOG_FILE = os.path.join(CONFIG_DIR, "sing-box.log")
SUBSCRIPTION_FILE = os.path.join(CONFIG_DIR, "sub.txt")
DECODED_FILE = os.path.join(CONFIG_DIR, "decoded.txt")
URL_FILE = os.path.join(CONFIG_DIR, "subscription_url.txt")


def read_subscription_url():
    if not os.path.isfile(URL_FILE):
        print(f"ERROR: subscription_url.txt not found at {URL_FILE}")
        sys.exit(1)
    url = open(URL_FILE).read().strip()
    if not url:
        print("ERROR: subscription_url.txt is empty")
        sys.exit(1)
    return url


def download_subscription(url):
    print("下载订阅中...")
    result = subprocess.run(
        ["curl", "-L", url, "-o", SUBSCRIPTION_FILE],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"ERROR: 下载失败\n{result.stderr}")
        sys.exit(1)
    print("下载完成，解码 Base64...")
    # 尝试两种 base64 解码方式
    r1 = subprocess.run(
        ["base64", "-d", SUBSCRIPTION_FILE],
        capture_output=True, text=True
    )
    if r1.returncode == 0:
        with open(DECODED_FILE, "w") as f:
            f.write(r1.stdout)
    else:
        r2 = subprocess.run(
            ["base64", "--decode", SUBSCRIPTION_FILE],
            capture_output=True, text=True
        )
        if r2.returncode != 0:
            print(f"ERROR: Base64 解码失败\n{r2.stderr}")
            sys.exit(1)
        with open(DECODED_FILE, "w") as f:
            f.write(r2.stdout)
    print("解码完成")


def parse_anytls(line: str):
    line = line.strip()
    if not line.startswith("anytls://"):
        return None
    u = urlparse(line)
    q = parse_qs(u.query)
    name = unquote(u.fragment) if u.fragment else ""
    server = u.hostname
    port = u.port
    password = unquote(u.username or "")
    sni = (q.get("sni") or q.get("peer") or q.get("server_name") or [""])[0]
    # 20260525: 得这样替换才能跑通
    if sni.strip() == "":
        sni = server.replace(".beibei1.top", ".hobbyx.cn")
    return {"name": name, "server": server, "port": port, "password": password, "sni": sni}


def load_nodes():
    if not os.path.isfile(DECODED_FILE):
        print(f"ERROR: decoded.txt not found at {DECODED_FILE}")
        sys.exit(1)
    with open(DECODED_FILE, "r", encoding="utf-8", errors="ignore") as f:
        lines = [x.strip() for x in f if x.strip()]
    nodes = [parse_anytls(l) for l in lines if parse_anytls(l)]
    if not nodes:
        print("ERROR: no anytls nodes found.")
        sys.exit(1)
    return nodes


def generate_config(node):
    sni = node["sni"] if node["sni"] else node["server"]
    config = {
        "log": {"level": "debug"},
        "inbounds": [
            {"type": "mixed", "tag": "mixed-in", "listen": "127.0.0.1", "listen_port": 7890}
        ],
        "outbounds": [
            {
                "type": "anytls",
                "tag": "anytls-out",
                "server": node["server"],
                "server_port": node["port"],
                "password": node["password"],
                "tls": {"enabled": True, "server_name": sni},
            },
            {"type": "direct", "tag": "direct"},
        ],
        "route": {"final": "anytls-out"},
    }
    os.makedirs(CONFIG_DIR, exist_ok=True)
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)
    print(f"配置已写入 {CONFIG_FILE}")


def restart_singbox():
    print("停掉已有 sing-box...")
    subprocess.run(
        ["pkill", "-f", f"sing-box run -c {CONFIG_FILE}"],
        capture_output=True
    )
    print("启动 sing-box...")
    with open(LOG_FILE, "w") as log:
        subprocess.Popen(
            ["sing-box", "run", "-c", CONFIG_FILE],
            stdout=log, stderr=log,
            start_new_session=True,
        )
    print(f"sing-box 已后台启动\nlog: {LOG_FILE}")


def main():
    # 1. 读取订阅 URL
    url = read_subscription_url()

    # 2. 询问是否更新订阅
    update = questionary.confirm("是否更新订阅?", default=True).ask()
    if update is None:
        print("已取消")
        sys.exit(0)
    if update:
        download_subscription(url)
    else:
        if not os.path.isfile(DECODED_FILE):
            print(f"ERROR: 未找到已缓存的订阅文件 {DECODED_FILE}，请先更新订阅")
            sys.exit(1)
        print("使用已有订阅缓存")

    # 3. 解析节点
    nodes = load_nodes()

    # 4. 选择节点
    choices = [
        questionary.Choice(
            title=f"[{i}] {n['name'] or '(no name)'}",
            value=i - 1,
        )
        for i, n in enumerate(nodes, 1)
    ]
    selected_idx = questionary.select("选择节点:", choices=choices).ask()
    if selected_idx is None:
        print("已取消")
        sys.exit(0)
    selected = nodes[selected_idx]

    # 5. 生成配置 & 重启 sing-box
    generate_config(selected)
    restart_singbox()

    # 6. 打印使用的节点
    print()
    print("=" * 50)
    print(f"  已切换节点: {selected['name'] or '(no name)'}")
    print(f"  server: {selected['server']}:{selected['port']}")
    print(f"  sni:    {selected['sni'] or selected['server']}")
    print("=" * 50)


if __name__ == "__main__":
    main()
