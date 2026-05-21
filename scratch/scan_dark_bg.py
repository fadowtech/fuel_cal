def main():
    with open('lib/main.dart', 'r', encoding='utf-8') as f:
        content = f.readlines()
        
    for idx, line in enumerate(content):
        if '0xFF151821' in line:
            print(f"{idx+1}: {line.strip()}")

if __name__ == '__main__':
    main()
