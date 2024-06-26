import subprocess
cmd = "chmod +x ./start.sh && ./start.sh"
subprocess.call(cmd, shell=True)
