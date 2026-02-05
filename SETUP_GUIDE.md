# SmartShow Ultimate - Complete Setup Guide

## 🚀 Quick Setup Instructions

### Prerequisites
1. **Python 3.8+** installed
2. **PostgreSQL** installed and running
3. **Git** (optional, for cloning)

### Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Setup PostgreSQL Database
1. **Start PostgreSQL service**
2. **Create database** (optional - app will create automatically):
   ```sql
   psql -U postgres
   CREATE DATABASE cinebook;
   ```

### Step 3: Run the Application
```bash
streamlit run smartshow_ultimate_ENHANCED_15_SHOWS.py
```

### Step 4: Database Setup in App
1. **Enter PostgreSQL password** when prompted
2. **Click "Reset & Create Fresh DB"** for first-time setup
3. **Wait for database creation** (will show success message)

### Step 5: Login
**Default Admin Credentials:**
- Username: `admin`
- Password: `Admin@123`

**Or create new user account**

## 📊 What You Get

### 🎬 Movies (40 Total)
- **4 Moods**: Romantic, Action, Comedy, Family
- **10 movies per mood**
- **56 theaters** across 8 areas

### 😂 Comedy Shows (15 Total)
- **Top comedians**: Kapil Sharma, Zakir Khan, Biswa, Kenny Sebastian, Vir Das, etc.
- **Price range**: ₹500-₹700
- **16 comedy venues** across 8 areas

### 🎵 Concerts (15 Total)
- **Top artists**: Arijit Singh, A.R. Rahman, Shreya Ghoshal, Sonu Nigam, etc.
- **Multiple genres**: Bollywood, Classical, Electronic, Sufi, Hip-Hop, Rock
- **Price range**: ₹750-₹1500
- **16 concert venues** across 8 areas

### 🏢 Areas Covered (8 Total)
1. **Satellite** - 7 theaters, 2 comedy venues, 2 concert venues
2. **Vastrapur** - 7 theaters, 2 comedy venues, 2 concert venues
3. **Paldi** - 7 theaters, 2 comedy venues, 2 concert venues
4. **Thaltej** - 7 theaters, 2 comedy venues, 2 concert venues
5. **Bopal** - 7 theaters, 2 comedy venues, 2 concert venues
6. **Maninagar** - 7 theaters, 2 comedy venues, 2 concert venues
7. **Naranpura** - 7 theaters, 2 comedy venues, 2 concert venues
8. **Chandkheda** - 7 theaters, 2 comedy venues, 2 concert venues

## 🛠️ Troubleshooting

### Database Connection Issues
1. **Check PostgreSQL is running**:
   ```bash
   # Windows
   net start postgresql-x64-13
   
   # Linux/Mac
   sudo service postgresql start
   ```

2. **Verify password**: Make sure you enter correct PostgreSQL password

3. **Reset database**: Use "Reset & Create Fresh DB" button if issues persist

### Python Package Issues
```bash
# Upgrade pip first
pip install --upgrade pip

# Install packages individually if bulk install fails
pip install streamlit
pip install psycopg2-binary
pip install pandas
pip install plotly
pip install numpy
```

### Port Issues
If port 8501 is busy:
```bash
streamlit run smartshow_ultimate_ENHANCED_15_SHOWS.py --server.port 8502
```

## 📁 File Structure
```
smartshow_ultimate_ENHANCED_15_SHOWS.py    # Main application
smartshow_ultimate_ENHANCED_15_SHOWS_database.sql    # Complete database setup
requirements.txt                            # Python dependencies
SMARTSHOW_ENHANCED_15_SHOWS_SUMMARY.md    # Feature documentation
SETUP_GUIDE.md                             # This setup guide
```

## 🎯 Key Features

### For Users:
- **Area-based registration** and entertainment discovery
- **Mood-based movie selection** (Romantic, Action, Comedy, Family)
- **15 comedy shows** with top comedians
- **15 concerts** across multiple genres
- **Real-time availability** tracking
- **Secure booking system**

### For Admins:
- **Complete dashboard** with analytics
- **Booking management**
- **Revenue tracking**
- **User management**
- **Venue management**

## 📈 Database Statistics
- **Total Entertainment Events**: 70 (40 movies + 15 comedy + 15 concerts)
- **Total Theaters**: 56 (7 per area × 8 areas)
- **Total Venues**: 32 (16 comedy + 16 concert venues)
- **Areas Covered**: 8 major areas in Ahmedabad

## 🔧 Manual Database Setup (Optional)
If you prefer to setup database manually:

```bash
# Connect to PostgreSQL
psql -U postgres

# Run the database script
\i smartshow_ultimate_ENHANCED_15_SHOWS_database.sql
```

## 📞 Support
If you face any issues:
1. **Check PostgreSQL is running**
2. **Verify Python version** (3.8+ required)
3. **Try "Reset & Create Fresh DB"** in the app
4. **Check console for error messages**

## 🎉 Success Indicators
- ✅ App opens in browser (usually http://localhost:8501)
- ✅ Database setup shows "Enhanced Database is ready!"
- ✅ You can see "15 Comedy Shows & 15 Concerts available!"
- ✅ Login works with admin credentials
- ✅ All entertainment options are visible

Enjoy your complete entertainment booking system! 🎬😂🎵