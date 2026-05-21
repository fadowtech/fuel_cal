def main():
    with open('lib/main.dart', 'r', encoding='utf-8') as f:
        content = f.readlines()
        
    for line_num in [1367, 1411, 1738, 1784, 1802, 2107, 2418, 2729]:
        print(f"=== Line {line_num} ===")
        for idx in range(max(0, line_num - 15), min(len(content), line_num + 3)):
            print(f"{idx+1}: {content[idx].rstrip()}")

if __name__ == '__main__':
    main()
