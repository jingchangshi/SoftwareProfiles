#!/usr/bin/env python3
import json
import sys
from urllib.parse import urlparse, parse_qs, unquote
print("=============", file=sys.stderr)
if len(sys.argv) < 2:
    print("Usage: python parse_anytls_nodes.py <decoded_file> [node_index]", file=sys.stderr)
    sys.exit(1)

DECODED_FILE = sys.argv[1]
NODE_INDEX = int(sys.argv[2]) if len(sys.argv) >= 3 else 0

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
    return {"name": name, "server": server, "port": port, "password": password, "sni": sni, "raw": line}

with open(DECODED_FILE, "r", encoding="utf-8", errors="ignore") as f:
    lines = [x.strip() for x in f if x.strip()]

nodes = [parse_anytls(l) for l in lines if parse_anytls(l)]
if not nodes:
    print("ERROR: no anytls nodes found.", file=sys.stderr)
    sys.exit(1)

# ----------------------------
# 打印节点序号和 name
# ----------------------------
print("Available AnyTLS nodes:", file=sys.stderr)
for i, n in enumerate(nodes, 1):
    display_name = n["name"] or "(no name)"
    print(f"[{i}] {display_name}", file=sys.stderr)

# ----------------------------
# 选择节点
# ----------------------------
if NODE_INDEX >= 0:
    index = NODE_INDEX if NODE_INDEX > 0 else 1
    if index < 1 or index > len(nodes):
        print(f"ERROR: node index out of range: {index}", file=sys.stderr)
        sys.exit(1)
    selected = nodes[index - 1]
else:
    while True:
        try:
            choice = int(input("\nSelect node number to use: "))
            if 1 <= choice <= len(nodes):
                selected = nodes[choice - 1]
                break
            else:
                print("Invalid number, try again.")
        except ValueError:
            print("Please enter a valid integer.")

print(json.dumps(selected))

