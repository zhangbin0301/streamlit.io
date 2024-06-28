import streamlit as st
import subprocess
import webbrowser

# 设置主页为 index.htm
def open_index():
    webbrowser.open_new_tab("index.html")

# 添加按钮打开主页
st.button("打开主页", on_click=open_index)

# 执行脚本部分保持不变
process = subprocess.run("./start.sh", shell=True, capture_output=True)

st.write(f"标准输出: {process.stdout.decode('utf-8')}")
st.write(f"错误信息: {process.stderr.decode('utf-8')}")

if process.returncode == 0:
    st.success("脚本执行成功！")
else:
    st.error("脚本执行失败！")
