import sqlite3
import json
import os
import re

def export_database_to_optimum_json(db_path, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # 1. Fetch all hymn books
    cursor.execute("SELECT id, name FROM hymn_book")
    books = cursor.fetchall()

    for book in books:
        book_id = book['id']
        book_name = book['name']
        print(f"Exporting Book: {book_name}")

        # 2. Fetch all hymns for this book
        cursor.execute("""
            SELECT id, hymn_number, title, other_reference 
            FROM hymn 
            WHERE hymn_book_id = ? 
            ORDER BY hymn_number, id
        """, (book_id,))
        hymns = cursor.fetchall()

        book_data = []

        for hymn in hymns:
            h_id = hymn['id']
            h_num = hymn['hymn_number']
            h_title = hymn['title']
            h_other = hymn['other_reference']

            hymn_entry = {
                "number": h_num,
                "title": h_title,
                "other_reference": h_other,
                "sections": []
            }

            # Fetch sections
            cursor.execute("""
                SELECT id, section_type, title as section_title 
                FROM section 
                WHERE hymn_id = ? 
                ORDER BY sequence
            """, (h_id,))
            sections = cursor.fetchall()

            for section in sections:
                s_id = section['id']
                s_type = section['section_type']
                s_title = section['section_title']

                # Fetch phrases
                cursor.execute("""
                    SELECT content, repeat_count 
                    FROM phrase 
                    WHERE section_id = ? 
                    ORDER BY sequence
                """, (s_id,))
                phrases_rows = cursor.fetchall()

                phrases = []
                for p in phrases_rows:
                    content = p['content'].strip()
                    repeat = p['repeat_count']
                    # Use standard (2x) format if repeat > 1 and not already encoded
                    if repeat > 1 and not re.search(r'\(\d+x?\)', content):
                        content = f"{content} ({repeat}x)"
                    phrases.append(content)
                
                hymn_entry["sections"].append({
                    "type": s_type,
                    "title": s_title,
                    "phrases": phrases
                })

            book_data.append(hymn_entry)

        # 4. Save to JSON
        safe_name = "".join([c if c.isalnum() else "_" for c in book_name]).lower()
        file_path = os.path.join(output_dir, f"backup_{safe_name}.json")
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(book_data, f, ensure_ascii=False, indent=2)
        
        print(f"Saved: {file_path}")

    conn.close()

if __name__ == "__main__":
    DB_PATH = "assets/databases/donkiliw_app.db"
    OUTPUT_DIR = "assets/json_books/backups"
    export_database_to_optimum_json(DB_PATH, OUTPUT_DIR)
