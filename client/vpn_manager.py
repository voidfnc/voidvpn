import dearpygui.dearpygui as dpg

# Dummy user token for demonstration
VALID_TOKEN = "abc123TOKEN"

# Dummy VPN data for demonstration
DUMMY_VPN_FILE_CONTENT = "client\nremote 1.2.3.4 1194\nproto udp\n..."
DUMMY_VPN_STATUS = "Connected"
DUMMY_VPN_NETWORK = "10.8.0.2/24"

def login_callback(sender, app_data, user_data):
    token = dpg.get_value("token_input")
    if token == VALID_TOKEN:
        dpg.configure_item("login_group", show=False)
        dpg.configure_item("main_group", show=True)
        dpg.set_value("login_status", "Login successful!")
    else:
        dpg.set_value("login_status", "Invalid token. Try again.")

def download_vpn_callback(sender, app_data, user_data):
    with open("vpn-config.ovpn", "w") as f:
        f.write(DUMMY_VPN_FILE_CONTENT)
    dpg.set_value("vpn_status_text", "VPN file downloaded as 'vpn-config.ovpn'.")

def check_status_callback(sender, app_data, user_data):
    status = f"VPN Status: {DUMMY_VPN_STATUS}\nNetwork: {DUMMY_VPN_NETWORK}"
    dpg.set_value("vpn_status_text", status)

dpg.create_context()
dpg.create_viewport(title='VPN Portal', width=400, height=300)

with dpg.window(label="VPN Portal", tag="main_window", width=400, height=300, no_resize=True, no_move=True, no_collapse=True, no_close=True):
    with dpg.group(tag="login_group"):
        dpg.add_text("Enter your registration token:")
        dpg.add_input_text(label="Token", tag="token_input", password=True)
        dpg.add_button(label="Login", callback=login_callback)
        dpg.add_text("", tag="login_status", color=[255, 0, 0])
    with dpg.group(tag="main_group", show=False):
        dpg.add_text("Welcome! Select an option below:")
        dpg.add_button(label="Download Latest VPN File", callback=download_vpn_callback)
        dpg.add_button(label="Check VPN Status / Network", callback=check_status_callback)
        dpg.add_separator()
        dpg.add_text("", tag="vpn_status_text")

dpg.setup_dearpygui()
dpg.show_viewport()
dpg.set_primary_window("main_window", True)  # Use the window's tag here!
dpg.start_dearpygui()
dpg.destroy_context()
