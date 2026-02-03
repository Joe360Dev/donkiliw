import json
import os
import sys
import re

def get_hymn_number_from_titre(titre):
    # Matches patterns like "83 Title", "83. Title", "0 Title"
    match = re.match(r'^(\d+)[\.\s]*', titre.strip())
    if match:
        return int(match.group(1))
    return None

def transform_json(input_path, output_path, start_number):
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading {input_path}: {e}")
        return

    transformed_data = []
    current_hymn_number = start_number

    for outer_item in data:
        if isinstance(outer_item, list):
            # Check if any title in this group has an explicit number
            found_num = None
            for item in outer_item:
                if 'titre' in item:
                    num = get_hymn_number_from_titre(item['titre'])
                    if num is not None:
                        found_num = num
                        break
            
            if found_num is not None:
                current_hymn_number = found_num

            # Find all titles and split
            current_sub_hymns = []
            temp_hymn_content = []
            
            for item in outer_item:
                if 'titre' in item:
                    if temp_hymn_content:
                        # Flush previous sub-hymn
                        current_sub_hymns.append(temp_hymn_content)
                        temp_hymn_content = []
                    temp_hymn_content.append(item)
                else:
                    temp_hymn_content.append(item)
            
            if temp_hymn_content:
                current_sub_hymns.append(temp_hymn_content)
            
            # Assign number to each split hymn in the group
            for hymn_content in current_sub_hymns:
                transformed_data.append({
                    "hymn_number": current_hymn_number,
                    "content": hymn_content
                })
            
            current_hymn_number += 1
        else:
            pass

    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(transformed_data, f, ensure_ascii=False, indent=2)
        print(f"Transformed {input_path} -> {output_path}")
    except Exception as e:
        print(f"Error writing {output_path}: {e}")

if __name__ == "__main__":
    books = [
        ("assets/json_books/betiba.json", "assets/json_books/betiba_v2.json", 1),
        ("assets/json_books/ala_tanu_donkiliw_1.json", "assets/json_books/ala_tanu_donkiliw_1_v2.json", 1),
        ("assets/json_books/ala_tanu_donkiliw_2.json", "assets/json_books/ala_tanu_donkiliw_2_v2.json", 1),
        ("assets/json_books/nii_don.json", "assets/json_books/nii_don_v2.json", 0),
    ]

    for input_file, output_file, start_num in books:
        transform_json(input_file, output_file, start_num)
