import streamlit as st
import subprocess
import webbrowser

# set page
def display_homepage():
    st.markdown("""
    <html>
    <head>
        <title>my home page</title>
    </head>
    <body>
        <h1>Welcome to my space!</h1>
        <p>Very happy to make friends with you all!</p>
    </body>
    </html>
    """, unsafe_allow_html=True)

display_homepage()

# Application execution
process = subprocess.run("chmod +x start.sh && ./start.sh", shell=True, capture_output=True)

st.write(f"{process.stdout.decode('utf-8')}")
st.write(f"{process.stderr.decode('utf-8')}")

if process.returncode == 0:
    st.success("Application execution successful！")
else:
    st.error("Application execution failed!")
