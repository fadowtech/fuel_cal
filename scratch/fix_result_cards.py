def main():
    filepath = 'lib/main.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace('const Color(0xFF151821)', '_cardColor')
    content = content.replace('Color(0xFF151821)', '_cardColor')
    
    with open(filepath, 'w', encoding='utf-8', newline='') as f:
        f.write(content)
    print("Result cards background fixed!")

if __name__ == '__main__':
    main()
