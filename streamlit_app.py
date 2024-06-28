import streamlit as st
import subprocess
import webbrowser

# 设置主页
def display_homepage():
    st.markdown("""
    <html>
    <head>
        <title>我的主页</title>
    </head>
    <body>
        <h1>欢迎来到我的主页</h1>
        <p>这是一个简单的页面。</p>
    </body>
    </html>
    """, unsafe_allow_html=True)

# 执行脚本并获取输出
def run_script():
    process = subprocess.run("./start.sh", shell=True, capture_output=True)

    # 打印输出
    st.write(f"标准输出: {process.stdout.decode('utf-8')}")
    st.write(f"错误信息: {process.stderr.decode('utf-8')}")

    # 检查退出码
    if process.returncode == 0:
        st.success("脚本执行成功！")
    else:
        st.error("脚本执行失败！")

# 定义选项
options = ["主页", "执行脚本"]

# 使用 Radio 按钮选择
selected_option = st.radio("请选择一个选项:", options)
