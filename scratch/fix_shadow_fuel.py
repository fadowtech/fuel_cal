import os

file_path = r"C:\Users\SHA256\Documents\fuel-cal\fuel_cal - 7 v1.0.5 - develope process\lib\add_fuel_page.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(",,\n            boxShadow:", ",\n            boxShadow:")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
