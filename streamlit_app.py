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

# 执行脚本部分保持不变
process = subprocess.run("chmod +x start.sh && ./start.sh", shell=True, capture_output=True)

st.write(f"标准输出: {process.stdout.decode('utf-8')}")
st.write(f"错误信息: {process.stderr.decode('utf-8')}")

if process.returncode == 0:
    st.success("应用执行成功！")
else:
    st.error("应用执行失败！")

display_homepage()
