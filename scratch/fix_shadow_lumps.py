import os

files = [
    'lib/add_expense_page.dart',
    'lib/add_fuel_page.dart',
    'lib/add_reminder_page.dart'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    while 'boxShadow: [' in content:
        idx = content.find('boxShadow: [')
        if idx == -1: break
        
        shadow_block = content[idx:idx+200]
        if '_neonColor' not in shadow_block or 'offset: const Offset(-4, 0)' not in shadow_block:
            content = content[:idx] + 'BOXSHADOW_PROCESSED' + content[idx+10:]
            continue
            
        container_idx = content.rfind('Container(', 0, idx)
        if container_idx == -1: break
            
        open_parens = 0
        end_idx = -1
        for i in range(container_idx + 9, len(content)):
            if content[i] == '(':
                open_parens += 1
            elif content[i] == ')':
                open_parens -= 1
                if open_parens == 0:
                    end_idx = i
                    break
                    
        if end_idx == -1: break
            
        container_str = content[container_idx:end_idx+1]
        
        margin_str = ""
        if 'margin:' in container_str:
            m_start = container_str.find('margin:')
            m_end = container_str.find(',', m_start)
            margin_str = container_str[m_start:m_end+1] + '\n          '
            
        padding_str = ""
        if 'padding:' in container_str:
            p_start = container_str.find('padding:')
            p_end = p_start
            p_parens = 0
            for i in range(p_start, len(container_str)):
                if container_str[i] == '(':
                    p_parens += 1
                elif container_str[i] == ')':
                    p_parens -= 1
                elif container_str[i] == ',' and p_parens == 0:
                    p_end = i
                    break
            padding_str = container_str[p_start:p_end+1] + '\n              '
            
        color_str = '_cardColor'
        if 'color: Colors.transparent' in container_str:
            color_str = 'Colors.transparent'
            
        radius_str = '12'
        if 'borderRadius: BorderRadius.circular(16)' in container_str:
            radius_str = '16'
        elif 'borderRadius: BorderRadius.circular(20)' in container_str:
            radius_str = '20'
            
        border_all_str = 'color: _surfaceColor'
        if 'border: Border.all(' in container_str:
            b_start = container_str.find('border: Border.all(') + 19
            b_end = b_start
            b_parens = 1
            for i in range(b_start, len(container_str)):
                if container_str[i] == '(':
                    b_parens += 1
                elif container_str[i] == ')':
                    b_parens -= 1
                    if b_parens == 0:
                        b_end = i
                        break
            border_all_str = container_str[b_start:b_end]
            
        c_start = container_str.find('child:')
        if c_start == -1: break
        child_str = container_str[c_start:-1].strip()
        if child_str.endswith(','):
            child_str = child_str[:-1].strip()
            
        inner_radius = int(radius_str) - 1
        
        new_container = f"""Container(
          {margin_str}decoration: BoxDecoration(
            borderRadius: BorderRadius.circular({radius_str}),
            border: Border.all({border_all_str}),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular({inner_radius}),
            child: Container(
              decoration: BoxDecoration(
                color: {color_str},
                border: Border(left: BorderSide(color: _neonColor, width: 4)),
              ),
              {padding_str}{child_str},
            ),
          ),
        )"""
        
        content = content[:container_idx] + new_container + content[end_idx+1:]
        
    content = content.replace('BOXSHADOW_PROCESSED', 'boxShadow: [')
    
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
