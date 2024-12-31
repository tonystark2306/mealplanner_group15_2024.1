# Meal Planner Application

## Project Overview
A web-based meal planning application that helps users organize their weekly meals, generate shopping lists, and manage recipes. The application supports meal scheduling, nutritional tracking, and personalized recipe recommendations.

### Key Features
- Weekly meal planning
- Recipe management and sharing
- Automatic shopping list generation
- Nutritional information tracking
- User preference customization

## Getting Started

You can run this application using either Docker Compose or by setting up a local development environment.

### Option 1: Running with Docker Compose

1. Prerequisites:
   - Docker and Docker Compose installed on your system
   - Git (for cloning the repository)

2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/mealplanner_group15_2024.1.git
   cd mealplanner_group15_2024.1
   ```

3. Start the application:
   ```bash
   docker-compose up -d
   ```

4. Access the application:
   - Open your browser and navigate to `http://localhost:3000`
   - The API will be available at `http://localhost:8080`

### Option 2: Local Development Setup

1. Prerequisites:
   - Python 3.8 or higher
   - Node.js 16 or higher
   - PostgreSQL 13 or higher

2. Backend Setup:
   ```bash
   # Create and activate virtual environment
   cd server
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   
   # Install dependencies
   pip install -r requirements.txt
   
   # Set up environment variables
   cp .env.example .env
   # Edit .env file with your database credentials
   
   # Initialize database
   flask db upgrade
   
   # Run the server
   flask run
   ```

3. Frontend Setup:
   ```bash
   # Install dependencies
   cd frontend
   flutter pub get
   
   # Run the application
   flutter run -d chrome
   ```

4. Access the application:
   - Frontend: `http://localhost:3000`
   - API: `http://localhost:5000`

## Support

For any issues or questions, please:
- Create an issue in our GitHub repository
- Contact our support team at support@mealplanner-group15.example.com

## License
This project is licensed under the MIT License - see the LICENSE file for details.

