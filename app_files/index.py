"""
One-time utility script to seed sample data into the land_rates table.
Not part of the running Flask application - run manually once after deployment
(Terraform's app_deploy module runs this automatically as a second step,
right after setup_vm.sh).

Reads DB connection details from the same environment variables used by
database.py (DB_HOST, DB_USER, DB_PASS, DB_NAME).
"""

import os
import pymysql

DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']

# Sample data across Andhra Pradesh and Telangana districts/mandals
SAMPLE_DATA = [
    ('Andhra Pradesh', 'Tirupati', 'Tirupati Rural', 4500.00, 13.6288, 79.4192),
    ('Andhra Pradesh', 'Tirupati', 'Chandragiri', 3200.00, 13.5936, 79.3145),
    ('Andhra Pradesh', 'Tirupati', 'Srikalahasti', 2800.00, 13.7497, 79.7037),
    ('Andhra Pradesh', 'Krishna', 'Vijayawada Urban', 6500.00, 16.5062, 80.6480),
    ('Andhra Pradesh', 'Guntur', 'Guntur Urban', 5800.00, 16.3067, 80.4365),
    ('Telangana', 'Hyderabad', 'Secunderabad', 9500.00, 17.4399, 78.4983),
    ('Telangana', 'Rangareddy', 'Shamshabad', 4100.00, 17.2403, 78.4294),
    ('Telangana', 'Warangal Urban', 'Hanamkonda', 3500.00, 17.9892, 79.5577),
]


def main():
    conn = pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        ssl={'ssl': True}
    )
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS land_rates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            state VARCHAR(100),
            district VARCHAR(100),
            mandal VARCHAR(100),
            rate DECIMAL(10,2),
            latitude DECIMAL(10,6),
            longitude DECIMAL(10,6)
        )
    ''')

    cursor.execute('SELECT COUNT(*) FROM land_rates')
    existing = cursor.fetchone()[0]
    if existing > 0:
        print(f"land_rates already has {existing} rows - skipping seed.")
        cursor.close()
        conn.close()
        return

    cursor.executemany(
        '''INSERT INTO land_rates (state, district, mandal, rate, latitude, longitude)
           VALUES (%s, %s, %s, %s, %s, %s)''',
        SAMPLE_DATA
    )
    conn.commit()

    print(f"Inserted {cursor.rowcount} rows into land_rates.")

    cursor.close()
    conn.close()


if __name__ == '__main__':
    main()
