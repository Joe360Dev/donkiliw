import json
import re
import os

def clean_text(text):
    # Remove leading verse numbers like "1. ", "1.", "1) ", etc.
    text = re.sub(r'^\d+[\.\)]\s*', '', text.strip())
    # Remove leading tabs
    text = text.replace('\t', ' ')
    # Normalize multiple spaces
    text = re.sub(r' +', ' ', text)
    return text.strip()

def parse_txt(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split content into parts starting with [Title], [Verse], or [Refrain]
    parts = re.split(r'(\[(?:Title|Verse|Refrain)\])', content)
    
    hymns = []
    current_hymn = None
    current_tag = None
    
    for part in parts:
        part = part.strip()
        if not part:
            continue
        
        if part in ['[Title]', '[Verse]', '[Refrain]']:
            current_tag = part
            continue
        
        if current_tag == '[Title]':
            lines = [l.strip() for l in part.split('\n') if l.strip()]
            if not lines: continue
            
            # The first line contains the number and title
            title_line = lines[0]
            
            # Extract leading number
            num_match = re.search(r'^(\d+)', title_line)
            if num_match:
                hymn_num = int(num_match.group(1))
                # Title is everything after the number
                title = title_line[len(num_match.group(0)):].strip()
            else:
                hymn_num = 0
                title = title_line
            
            # If there are subsequent lines in the title block, join them to the title
            if len(lines) > 1:
                title += " " + " ".join(lines[1:])
            
            current_hymn = {
                "hymn_number": hymn_num,
                "content": [{"titre": title}]
            }
            
            hymns.append(current_hymn)
                
        elif current_tag == '[Verse]':
            if current_hymn is not None:
                cleaned = clean_text(part)
                current_hymn["content"].append({"couple": cleaned})
                
        elif current_tag == '[Refrain]':
            if current_hymn is not None:
                # Refrains usually don't have leading numbers but we can clean anyway
                cleaned = clean_text(part)
                current_hymn["content"].append({"refrain": cleaned})
                
    return hymns

def main():
    base_path = "assets/json_books"
    files = ["ama somu nii.txt", "nii dɔn kana dagi.txt"]
    
    for filename in files:
        txt_path = os.path.join(base_path, filename)
        if not os.path.exists(txt_path):
            # Try absolute path if relative fails (though I am in Cwd)
            txt_path = os.path.join("/Users/joe360dev/Projects/Flutter/donkiliw/assets/json_books", filename)
            
        if not os.path.exists(txt_path):
            print(f"Skipping {txt_path}, not found.")
            continue
            
        print(f"Parsing {txt_path}...")
        hymns = parse_txt(txt_path)
        
        # Determine output filename
        # Normalize name: lowercase, replace spaces for consistency
        out_name = filename.lower().replace(" ", "_").replace(".txt", ".json")
        out_path = os.path.join(base_path, out_name)
        
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(hymns, f, ensure_ascii=False, indent=2)
        print(f"Saved {len(hymns)} hymns to {out_path}")

if __name__ == "__main__":
    main()
