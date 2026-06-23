import os
import pymysql

class DataTier:
    def __init__(self):
        self.host = os.environ.get('DB_HOST', 'dbserversai.mysql.database.azure.com')
        self.user = os.environ.get('DB_USER', 'azsqladmin')
        self.password = os.environ.get('DB_PASS', '')
        self.database = os.environ.get('DB_NAME', 'real_estate')
        self._setup()

    def _get_connection(self):
        return pymysql.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            database=self.database,
            ssl={'ssl': True}
        )

    def _setup(self):
        conn = self._get_connection()
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
        conn.commit()
        cursor.close()
        conn.close()

    def get_states(self):
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT DISTINCT state FROM land_rates ORDER BY state')
        states = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return states

    def get_districts(self, state):
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT DISTINCT district FROM land_rates WHERE state=%s ORDER BY district', (state,))
        districts = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return districts

    def get_mandals(self, state, district):
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT DISTINCT mandal FROM land_rates WHERE state=%s AND district=%s ORDER BY mandal', (state, district))
        mandals = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return mandals

    def get_mandal_info(self, state, district, mandal):
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT rate, latitude, longitude FROM land_rates WHERE state=%s AND district=%s AND mandal=%s', (state, district, mandal))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return result
