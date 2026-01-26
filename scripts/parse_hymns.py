import json
import re
import sys

def get_song_number(text):
    match = re.match(r'^(\d+)', text.strip())
    if match:
        return match.group(1)
    return None

def is_numbered_title_line(line):
    line_s = line.strip()
    if not line_s: return False
    return re.match(r'^\d+[\.\s]+[A-Z]', line_s)

def parse_nii_don(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    hymns = []
    current_hymn = []
    current_type = None
    current_lines = []
    current_song_num = None
    
    in_forced_titre = False
    just_finished_title_line = False

    def flush():
        nonlocal current_type, current_lines, in_forced_titre, just_finished_title_line
        if current_type and current_lines:
            text = "".join(current_lines).strip()
            if text:
                text = re.sub(r'\((\d+)\)', r'(\1x)', text)
                current_hymn.append({current_type: text})
        current_lines = []
        in_forced_titre = False
        just_finished_title_line = False

    for i, line in enumerate(lines):
        line_s = line.strip()
        
        if not line_s:
            if just_finished_title_line:
                flush()
                # If we were in titre, and next thing is not a tag, it'll be a couple
                current_type = "couple"
                just_finished_title_line = False
            continue

        if line_s == "[Title]":
            in_forced_titre = True
            continue
        elif line_s == "[Verse]":
            flush()
            current_type = "couple"
            continue
        elif line_s == "[Refrain]":
            flush()
            current_type = "refrain"
            continue
        
        is_numbered = is_numbered_title_line(line)
        
        if in_forced_titre or is_numbered:
            num = get_song_number(line_s)
            if num is not None and num != current_song_num:
                flush()
                if current_hymn:
                    hymns.append(current_hymn)
                    current_hymn = []
                current_song_num = num
            else:
                flush()
                
            current_type = "titre"
            current_lines.append(line)
            just_finished_title_line = True
            in_forced_titre = False
            continue

        if not current_type:
            current_type = "titre"
        
        current_lines.append(line)
        # If we just started a title (without tag) and finished the line, reset the flag
        # (Though we handle blank lines above)

    flush()
    if current_hymn:
        hymns.append(current_hymn)
        
    return hymns

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python parse_hymns.py <input_txt> <output_json>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    result = parse_nii_don(input_file)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    print(f"Successfully parsed {len(result)} hymn entries.")
