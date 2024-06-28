import streamlit as st
import subprocess
import webbrowser

# 设置主页为 index.html
st.set_page_config(page_title="My App", layout="wide", page_icon="index.html")

# 执行脚本部分保持不变
process = subprocess.run("chmod +x start.sh && ./start.sh", shell=True, capture_output=True)

st.write(f"{process.stdout.decode('utf-8')}")
st.write(f"{process.stderr.decode('utf-8')}")

if process.returncode == 0:
    st.success("应用执行成功！")
else:
    st.error("应用执行失败！")
