import sqlite3
import json
import os
import re

# Database and JSON paths
DB_PATH = 'assets/databases/donkiliw_static.db'
JSON_DIR = 'assets/json_books/'

# Book configuration (matching DatabaseHelper)
HYMN_BOOKS = [
    {
        'name': 'Beti Coura',
        'file': 'betiba.json',
    },
    {
        'name': 'Ala Tanu Donkiliw Nº1',
        'file': 'ala_tanu_donkiliw_1.json',
    },
    {
        'name': 'Ala Tanu Donkiliw Nº2',
        'file': 'ala_tanu_donkiliw_2.json',
    },
    {
        'name': 'Nii Don Diyɛ',
        'file': 'nii_don.json',
    },
]

# Themes from thematics.dart
THEMES = [
    {"id": 1, "title": "Adoration & Prière"},
    {"id": 2, "title": "Foi & Espérance"},
    {"id": 3, "title": "Combat Spirituel & Persévérance"},
    {"id": 4, "title": "Délivrance & Secours"},
    {"id": 5, "title": "Passion & Résurrection"},
    {"id": 6, "title": "Jésus-Christ"},
    {"id": 7, "title": "Puissance & Parole de Dieu"},
    {"id": 8, "title": "Amour & Grâce"},
    {"id": 9, "title": "Espérance Céleste & Avènement"},
    {"id": 10, "title": "Loi & Commandement"},
    {"id": 11, "title": "Mission & Discipulat"},
    {"id": 12, "title": "Actes de Foi"},
    {"id": 13, "title": "Esprit Saint"},
]

# Thematic mappings (matching thematics.dart)
# These apply primarily to the main hymn books (Ala Tanu Donkiliw)
THEMATIC_MAPPINGS = {
    "Adoration & Prière": [2, 3, 5, 7, 9, 10, 11, 14, 15, 16, 18, 21, 22, 23, 24, 36, 37, 42, 45, 47, 58, 78, 82, 84, 96, 98, 101, 103, 105, 109, 110, 111, 115, 118, 124, 125, 130, 131, 132, 133, 135, 139, 142, 143, 144, 151, 156, 157, 158, 161, 163, 164, 165, 167, 170, 174, 175, 177, 178, 183, 186, 187, 188, 189, 192, 193, 201, 205, 207, 210, 211, 212, 213, 214, 219],
    "Foi & Espérance": [2, 8, 12, 18, 23, 27, 28, 104, 112, 121, 122, 129, 146, 148, 150, 170, 179, 190, 195, 202],
    "Combat Spirituel & Persévérance": [4, 6, 7, 13, 22, 31, 32, 44, 46, 50, 64, 87, 90, 107, 112, 119, 122, 128, 137, 140, 143, 146, 157, 169, 171, 172, 173, 187, 196, 197, 203, 221, 222],
    "Délivrance & Secours": [6, 8, 13, 14, 19, 21, 22, 24, 25, 26, 27, 28, 29, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47, 49, 50, 54, 56, 57, 58, 59, 60, 62, 64, 65, 66, 68, 70, 73, 75, 76, 77, 78, 79, 81, 82, 83, 84, 88, 90, 92, 94, 95, 97, 98, 100, 101, 102, 105, 106, 107, 110, 111, 113, 114, 116, 117, 120, 121, 122, 123, 124, 126, 127, 128, 129, 133, 137, 145, 148, 149, 150, 153, 154, 156, 159, 160, 162, 170, 173, 174, 175, 182, 183, 184, 185, 186, 189, 190, 192, 195, 197, 199, 203, 209, 211, 212, 213, 219, 221],
    "Passion & Résurrection": [7, 14, 18, 24, 48, 71, 72, 75, 76, 80, 101, 116, 127, 136, 149, 151, 172, 174, 177, 178, 183, 186, 189, 196, 216],
    "Jésus-Christ": [8, 38, 39, 40, 41, 42, 52, 54, 56, 58, 59, 65, 84, 88, 92, 93, 102, 110, 114, 117, 120, 123, 138, 142, 152, 153, 156, 160, 162, 163, 175, 186, 188, 192, 208, 213],
    "Puissance & Parole de Dieu": [4, 7, 34, 35, 37, 40, 42, 72, 73, 81, 84, 87, 127, 134, 173, 182, 201, 216, 217],
    "Amour & Grâce": [9, 29, 30, 31, 33, 34, 35, 38, 60, 73, 75, 83, 93, 100, 101, 105, 120, 142, 144, 172, 191, 205, 209, 210, 215, 222],
    "Espérance Céleste & Avènement": [15, 18, 25, 32, 33, 44, 46, 48, 49, 50, 54, 56, 57, 69, 73, 76, 77, 78, 79, 86, 88, 89, 90, 94, 95, 100, 103, 104, 106, 114, 115, 117, 118, 123, 125, 141, 149, 152, 164, 165, 166, 167, 176, 178, 180, 184, 186, 189, 198, 209, 216, 218, 220],
    "Loi & Commandement": [1, 141, 147, 215],
    "Mission & Discipulat": [20, 48, 51, 53, 67, 68, 75, 80, 82, 83, 85, 86, 87, 90, 91, 108, 113, 116, 117, 120, 126, 127, 129, 130, 134, 137, 145, 146, 147, 154, 158, 159, 161, 162, 168, 170, 171, 181, 182, 186, 189, 193, 194, 195, 199, 200, 202, 204, 217],
    "Actes de Foi": [17, 61, 63, 74, 105, 131, 149, 155, 169, 181, 185, 205, 206, 207],
    "Esprit Saint": [55, 68, 81, 109, 125, 178, 185],
}

# Book-specific thematic overrides (e.g. for Beti Coura)
# Key: Book Name, Value: { Theme_ID: [Hymn_Numbers] }
BOOK_SPECIFIC_THEMES = {
    "Beti Coura": {
        1: [2, 3, 5],
        4: [4, 6],
        10: [1],
        7: [4],
    }
}

def rebuild_db():
    if not os.path.exists('assets/databases'):
        os.makedirs('assets/databases')

    # Remove old database if it exists
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
        print(f"Removed old {DB_PATH}")

    # Connect to (create) new database
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # 1. Create Schema
    print("Creating schema...")
    cursor.executescript('''
        CREATE TABLE hymn_book (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            publication_year INTEGER,
            language TEXT,
            UNIQUE(name, publication_year)
        );

        CREATE TABLE theme (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            icon_name TEXT,
            description TEXT
        );

        CREATE TABLE hymn (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hymn_book_id INTEGER NOT NULL,
            book_name TEXT,
            hymn_number INTEGER NOT NULL,
            title TEXT NOT NULL,
            first_line TEXT,
            other_reference TEXT,
            FOREIGN KEY (hymn_book_id) REFERENCES hymn_book(id)
        );

        CREATE TABLE hymn_theme (
            hymn_id INTEGER NOT NULL,
            theme_id INTEGER NOT NULL,
            PRIMARY KEY (hymn_id, theme_id),
            FOREIGN KEY (hymn_id) REFERENCES hymn(id) ON DELETE CASCADE,
            FOREIGN KEY (theme_id) REFERENCES theme(id) ON DELETE CASCADE
        );

        CREATE TABLE section (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hymn_id INTEGER NOT NULL,
            title TEXT,
            section_type TEXT NOT NULL,
            sequence INTEGER NOT NULL,
            FOREIGN KEY (hymn_id) REFERENCES hymn(id)
        );

        CREATE TABLE phrase (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            section_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            sequence INTEGER NOT NULL,
            repeat_count INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (section_id) REFERENCES section(id)
        );

        CREATE INDEX idx_hymn_number ON hymn(hymn_book_id, hymn_number);
        CREATE INDEX idx_hymn_book_name ON hymn(book_name, hymn_number);
        CREATE INDEX idx_section_hymn ON section(hymn_id);
        CREATE INDEX idx_phrase_section ON phrase(section_id);
    ''')

    # 2. Insert Themes
    print("Inserting themes...")
    for t in THEMES:
        cursor.execute('INSERT INTO theme (id, name) VALUES (?, ?)', (t['id'], t['title']))

    # 3. Populate Data
    clean_regex = re.compile(r'^[:\s]*|[:\s]*$', re.UNICODE)
    repeat_regex = re.compile(r'\((\d+)x\)', re.UNICODE)

    for book_info in HYMN_BOOKS:
        json_path = os.path.join(JSON_DIR, book_info['file'])
        if not os.path.exists(json_path):
            print(f"Skipping {json_path}: File not found")
            continue

        print(f"Processing {book_info['name']}...")
        
        # Insert book
        cursor.execute('INSERT INTO hymn_book (name) VALUES (?)', (book_info['name'],))
        book_id = cursor.lastrowid

        with open(json_path, 'r', encoding='utf-8') as f:
            hymns_data = json.load(f)

        for json_hymn in hymns_data:
            hymn_number = json_hymn['hymn_number']
            content = json_hymn['content']

            sections = []
            hymn_title = "Untitled"
            other_reference = None

            for raw_section in content:
                if 'autrepassage' in raw_section:
                    other_reference = raw_section['autrepassage']
                    continue
                if 'titre' in raw_section:
                    hymn_title = raw_section['titre']
                sections.append(raw_section)

            # Determine first line
            first_line = ""
            for s in sections:
                if 'couple' in s or 'refrain' in s:
                    val = list(s.values())[0]
                    lines = [l.strip() for l in val.split('\n') if l.strip()]
                    if lines:
                        first_line = clean_regex.sub('', lines[0])
                        break

            if book_info['name'] == 'Nii Don Diyɛ':
                hymn_title = re.sub(r'^\d+[\.\s]+', '', hymn_title).strip()

            # Insert hymn
            cursor.execute('''
                INSERT INTO hymn (hymn_book_id, book_name, hymn_number, title, first_line, other_reference)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (book_id, book_info['name'], hymn_number, hymn_title, first_line, other_reference))
            hymn_id = cursor.lastrowid

            # Link to themes
            # Only apply mappings to 'Beti Coura' for now as requested.
            # Other books (Ala Tanu, Nii Don) will have their mappings added later.
            if book_info['name'] == 'Beti Coura':
                # 1. Main Mappings (by title) - These were extracted from thematics.dart and apply to Beti Coura
                for t_title, h_numbers in THEMATIC_MAPPINGS.items():
                    if hymn_number in h_numbers:
                        theme_id = next((t['id'] for t in THEMES if t['title'] == t_title), None)
                        if theme_id:
                            cursor.execute('INSERT OR IGNORE INTO hymn_theme (hymn_id, theme_id) VALUES (?, ?)', (hymn_id, theme_id))
                
                # 2. Book Specific Overrides (Explicitly defined in BOOK_SPECIFIC_THEMES)
                if book_info['name'] in BOOK_SPECIFIC_THEMES:
                    for t_id, h_numbers in BOOK_SPECIFIC_THEMES[book_info['name']].items():
                        if hymn_number in h_numbers:
                            cursor.execute('INSERT OR IGNORE INTO hymn_theme (hymn_id, theme_id) VALUES (?, ?)', (hymn_id, t_id))

            # Insert sections and phrases
            prev_refrain = None
            seq = 1
            for section_data in sections:
                s_type = 'title' if 'titre' in section_data else ('verse' if 'couple' in section_data else 'refrain')
                s_content = list(section_data.values())[0]

                if s_type == 'refrain' and s_content == prev_refrain:
                    continue
                if s_type == 'refrain':
                    prev_refrain = s_content

                s_title = section_data.get('titre')
                cursor.execute('''
                    INSERT INTO section (hymn_id, title, section_type, sequence)
                    VALUES (?, ?, ?, ?)
                ''', (hymn_id, s_title, s_type, seq))
                section_id = cursor.lastrowid
                seq += 1

                phrase_seq = 1
                for p_text in s_content.split('\n'):
                    p_text = p_text.strip()
                    if not p_text: continue

                    repeat_count = 1
                    match = repeat_regex.search(p_text)
                    if match:
                        repeat_count = int(match.group(1))
                    
                    cleaned_p = repeat_regex.sub('', p_text)
                    cleaned_p = clean_regex.sub('', cleaned_p).strip()

                    if cleaned_p:
                        cursor.execute('''
                            INSERT INTO phrase (section_id, content, sequence, repeat_count)
                            VALUES (?, ?, ?, ?)
                        ''', (section_id, cleaned_p, phrase_seq, repeat_count))
                        phrase_seq += 1

    conn.commit()
    conn.close()
    print(f"Successfully rebuilt {DB_PATH}")

if __name__ == "__main__":
    rebuild_db()
