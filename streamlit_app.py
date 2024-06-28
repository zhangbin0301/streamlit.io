import streamlit as st
import subprocess

# 执行脚本并获取输出
process = subprocess.run("./start.sh", shell=True, capture_output=True)

# 打印输出
st.write(f"标准输出: {process.stdout.decode('utf-8')}")
st.write(f"错误信息: {process.stderr.decode('utf-8')}")

# 检查退出码
if process.returncode == 0:
    st.success("脚本执行成功！")
else:
    st.error("脚本执行失败！")
