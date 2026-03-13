# NutriLens Product Requirements Document

## 1. Product Summary

**Product name:** NutriLens

**Positioning statement:** A calorie and nutrition tracking app like MyFitnessPal, but with smarter food capture, disease-aware meal guidance, and simpler daily adherence.

**MVP statement:** A cross-platform calorie tracker with food search, barcode scan, meal logging, calorie and macronutrient tracking, hydration reminders, saved meals, and a basic dashboard using USDA FoodData Central and Open Food Facts.

## 2. Vision

NutriLens helps users log meals faster, understand nutrition more clearly, and stay consistent through reminders, repeatable meal flows, and health-aware guidance. The app should reduce friction compared with traditional calorie trackers while avoiding medical claims.

## 3. Goals

### Product goals

- Reduce meal logging time and effort.
- Improve daily adherence to calorie, macro, and hydration goals.
- Differentiate from generic calorie trackers with better capture flows and condition-aware nutrition guidance.
- Build a free-first product with a clean upgrade path to premium features.

### Business goals

- Increase day-1, day-7, and day-30 retention.
- Drive repeat logging behavior through saved meals, history, and reminders.
- Establish a scalable nutrition data layer for future OCR, AI vision, and coaching features.

## 4. Non-Goals For MVP

- Full AI food photo recognition as a primary logging method
- Clinical-grade disease management
- Social/community features
- Wearable integrations
- Family accounts
- Advanced meal plan automation

## 5. Target Users

### Primary user segments

- General fitness users tracking calories and macros
- Weight loss and weight gain users
- Busy users who need reminder-driven logging
- Users who want wellness-oriented nutrition guidance for diabetes-friendly, low-sodium, high-iron, or heart-friendly eating

### User constraints

- Limited time for meal logging
- Frequent repeat meals
- Mixed use of generic foods and packaged foods
- Need for simple, trustworthy guidance without clinical complexity

## 6. Core Value Propositions

- Faster logging through search, barcode scan, recents, favorites, and saved meals
- More complete tracking with macros plus key micronutrients
- Better adherence through reminders, streaks, and daily summaries
- Safer wellness guidance with rules-based condition-aware filters and explicit disclaimers

## 7. Functional Scope

### 7.1 User accounts and onboarding

Users can:

- Sign up, log in, and log out
- Create and edit a profile
- Set age, sex, height, weight, and activity level
- Choose a goal: lose, maintain, or gain
- Select dietary preferences and allergies
- Set health preference flags:
  - diabetes-friendly
  - low sodium
  - high iron
  - heart-friendly
- Review calculated daily targets:
  - calories
  - protein
  - carbs
  - fat
  - water
- Configure notification preferences

### 7.2 Food search and food detail

Users can:

- Search foods by name
- Search brand products
- View search results from generic and branded sources
- Open a food detail view with:
  - serving size
  - unit options
  - calories
  - macros
  - key micronutrients when available
  - source indicator
- Adjust serving quantity and unit before logging

### 7.3 Meal logging

Users can:

- Log foods into breakfast, lunch, dinner, or snacks
- Manually enter calories if food search fails
- Edit or delete meal entries
- Duplicate previous meals
- Save meals as templates
- Reuse recent foods and favorites
- Copy saved meals to another date

### 7.4 Nutrition tracking

Track:

- Calories
- Protein
- Carbohydrates
- Fat
- Fiber
- Sugar
- Sodium
- Potassium
- Iron
- Calcium
- Vitamin D
- Vitamin C
- Cholesterol

Views:

- Daily summary
- Weekly summary
- Per-meal nutrient breakdown
- Progress against targets

### 7.5 Hydration and reminders

Users can:

- Set a water target
- Log water intake
- Configure reminders for:
  - breakfast
  - lunch
  - snacks
  - dinner
  - water
  - missed log
  - evening summary
  - streak reminder
  - weekly progress

### 7.6 Camera-assisted logging

MVP:

- Barcode scanning for packaged foods
- Scan history and barcode history

Post-MVP:

- OCR for nutrition label extraction
- Plate or food photo capture
- AI-assisted food recognition with confidence and user confirmation

### 7.7 Recommendations

MVP:

- Basic meal suggestions based on calorie target, macro balance, dietary preference, and condition-aware filters

Post-MVP:

- Daily meal plans
- Grocery list generation
- Prep-by-week planning

### 7.8 Analytics and progress

Users can:

- Log body weight
- View weight trend
- View calorie adherence
- View macro adherence
- View water adherence
- Track streaks
- See common foods and nutrient source insights

## 8. User Stories

### Onboarding

- As a new user, I want to enter my profile and goal so the app can calculate useful daily nutrition targets.
- As a user with dietary restrictions, I want to set preferences once so recommendations and filters are relevant.

### Food logging

- As a user, I want to search and log a food quickly so meal tracking feels low effort.
- As a repeat user, I want my common meals to appear first so I can log with one tap.
- As a user scanning packaged foods, I want barcode lookup to return a product with serving info and nutrients.

### Tracking

- As a user, I want to see calories and macros remaining for the day so I can adjust my meals.
- As a health-aware user, I want to see sodium or iron totals so I can align food choices to my needs.

### Adherence

- As a busy user, I want reminders when I miss logging so I can stay consistent.
- As a user tracking hydration, I want water reminders and progress so I can meet my target.

### Guidance

- As a user with a low-sodium preference, I want meal suggestions filtered accordingly so I can make safer choices.
- As a user with diabetes-friendly preferences, I want educational guidance without the app acting like a clinician.

## 9. Acceptance Criteria

### Epic: Onboarding

- User can create an account and sign in successfully.
- User can complete profile setup in under 2 minutes.
- App calculates a daily calorie target from profile data and goal selection.
- User can edit targets after onboarding.

### Epic: Food search and logging

- Searching by food name returns results within 2 seconds for cached or normal requests.
- A food result displays calories and serving information before logging.
- User can change quantity and units before saving.
- Logged items are assigned to the selected meal bucket and date.
- User can edit and delete logged entries.

### Epic: Barcode scanning

- User can scan a barcode from the camera.
- App returns a product if found in packaged food data.
- If multiple matches or low-confidence data exist, user sees a confirmation screen.
- Scan history is stored and visible for repeat use.

### Epic: Dashboard

- Dashboard shows consumed calories, remaining calories, and macro progress for the current day.
- Dashboard shows meal buckets with totals.
- Dashboard updates immediately after a food is logged, edited, or deleted.

### Epic: Reminders

- User can enable and disable reminder types independently.
- Reminder times can be customized.
- Missed-log reminders trigger only when a relevant meal has not been logged.

### Epic: Saved meals and history

- User can save a combination of foods as a meal template.
- User can reuse recent foods and saved meals in under 2 taps.

## 10. Safety and Compliance Guardrails

- All condition-aware features are educational and wellness-oriented.
- The app must display a disclaimer such as: "NutriLens provides general wellness and nutrition support. It is not medical advice, diagnosis, or treatment."
- The app must not prescribe condition-specific intake limits without validated clinical review.
- Recommendations should be rules-based initially, not open-ended generative outputs.
- Source labeling must distinguish between verified database values and estimates.

## 11. Data Source Strategy

### Primary sources

- **USDA FoodData Central**
  - Use for generic foods and nutrient depth
  - Primary source for calories, macros, and key micronutrients

- **Open Food Facts**
  - Use for packaged and barcoded foods
  - Primary source for product lookup, brand packaging, and barcode flows

### Data trust labeling

Each logged food should carry a source badge:

- USDA
- Barcode database
- User-created
- OCR estimate
- AI photo estimate

### Data normalization requirements

- Normalize units across grams, ounces, servings, cups, tablespoons, and item counts
- Map nutrients into a single internal schema
- Deduplicate similar branded foods across data sources where possible
- Preserve original source metadata for traceability

## 12. System Architecture

### Frontend

- Flutter mobile app for iOS and Android
- ML Kit for on-device barcode scanning and OCR
- Firebase Cloud Messaging or APNs-backed push delivery

### Backend

- FastAPI service
- PostgreSQL database
- Redis for caching and short-lived search result acceleration
- Background job worker for reminders, sync jobs, and recommendation refreshes

### External integrations

- USDA FoodData Central API
- Open Food Facts API
- Firebase Cloud Messaging
- Apple Push Notification service
- Google ML Kit

## 13. Core Domain Model

### Entities

- `users`
- `user_goals`
- `notification_preferences`
- `condition_preferences`
- `foods_master`
- `food_sources`
- `food_servings`
- `food_nutrients`
- `meal_logs`
- `meal_log_items`
- `saved_meals`
- `saved_meal_items`
- `recipes`
- `recipe_items`
- `hydration_logs`
- `body_metrics`
- `scan_history`
- `recommendations`

### Key relationships

- A user has one profile and one active goal configuration
- A meal log belongs to a user and a calendar date
- Meal log items reference canonical food records plus selected serving/unit information
- Saved meals and recipes are reusable collections of food items
- Scan history stores barcode, matched food, timestamp, and resolution status

## 14. Suggested API Surface

### Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`

### Profile and preferences

- `GET /me`
- `PATCH /me`
- `GET /me/goals`
- `PATCH /me/goals`
- `GET /me/preferences`
- `PATCH /me/preferences`
- `GET /me/notifications`
- `PATCH /me/notifications`

### Foods

- `GET /foods/search?q=`
- `GET /foods/{food_id}`
- `GET /foods/barcode/{barcode}`
- `POST /foods/custom`

### Meal logs

- `GET /meal-logs?date=YYYY-MM-DD`
- `POST /meal-logs/items`
- `PATCH /meal-logs/items/{item_id}`
- `DELETE /meal-logs/items/{item_id}`
- `POST /meal-logs/copy`

### Saved meals and recipes

- `GET /saved-meals`
- `POST /saved-meals`
- `POST /saved-meals/{id}/log`
- `GET /recipes`
- `POST /recipes`

### Tracking and analytics

- `GET /dashboard?date=YYYY-MM-DD`
- `GET /analytics/weekly`
- `POST /hydration/logs`
- `POST /body-metrics`

### Recommendations

- `GET /recommendations/daily`

## 15. Rules-Based Guidance Logic

Initial guidance should use deterministic filters and scoring rules.

Examples:

- **Low sodium:** prefer foods below internal sodium thresholds; rank alternatives higher
- **Diabetes-friendly:** surface lower-sugar and balanced macro options; avoid treatment language
- **High iron:** highlight iron-rich foods and vitamin C pairings
- **Heart-friendly:** prefer lower saturated fat and lower sodium options

Constraints:

- Guidance is informational
- No disease diagnosis
- No personalized medical treatment suggestions

## 16. MVP Scope

### Must-have

- User auth
- Onboarding and profile setup
- Goal-based daily target calculation
- Food search
- Food detail and serving adjustment
- Meal logging across meal buckets
- Daily dashboard
- Calorie and macro tracking
- Water logging and reminders
- Barcode scanning
- Favorites, recents, and saved meals

### Nice-to-have

- Basic micronutrients: sodium, iron, calcium
- Weekly summaries
- Weight logging
- Simple condition-aware filters

### Excluded from MVP

- Full AI food photo recognition
- Advanced OCR nutrition label parsing
- Rich clinical meal planning
- Social features
- Wearables

## 17. Post-MVP Roadmap

### Phase 2

- OCR label scan
- Recipe builder
- Grocery lists
- Weekly analytics
- Expanded micronutrients
- Condition-based meal templates

### Phase 3

- AI plate recognition
- Voice logging
- Wearable integrations
- Coach or chat assistant
- Family account
- Community features
- Premium subscription system

## 18. Sprint Plan

### Sprint 1: Foundation

- Project scaffolding
- Auth
- User profile and goal setup
- Core database schema
- Push notification infrastructure

### Sprint 2: Food data and meal logging

- USDA integration
- Open Food Facts integration
- Unified search and normalization layer
- Meal logging flows
- Daily dashboard

### Sprint 3: Adherence and repeatability

- Water tracking
- Reminder scheduling
- Favorites
- Recents
- Saved meals

### Sprint 4: Packaging and guidance

- Barcode scanning
- Scan history
- Source badges
- Basic condition-aware rules
- Weekly summary

## 19. Success Metrics

- Day-1 retention
- Day-7 retention
- Day-30 retention
- Average meals logged per active user per day
- Search-to-log conversion rate
- Barcode scan success rate
- Saved meal reuse rate
- Reminder open-to-log conversion
- Weekly active users

## 20. Risks

### Technical risks

- Inconsistent food data across sources
- Unit normalization complexity
- Duplicate branded items
- Missing micronutrient data
- OCR extraction quality
- Food image recognition accuracy

### Product risks

- Logging fatigue
- Reminder fatigue
- Overpromising medical relevance
- Low retention after week one

## 21. Product Decisions

- Start with search plus barcode, not AI photo logging
- Use rules-based guidance before any AI recommendations
- Prioritize repeat-use flows like recents and saved meals early
- Treat source transparency as a first-class UX element
- Build around a unified internal food schema from day one

## 22. Open Questions

- What auth provider should be used initially: custom JWT, Firebase Auth, or Supabase Auth?
- Should the first release support both iOS and Android simultaneously, or sequence platforms?
- How much of Open Food Facts data should be cached locally vs fetched on demand?
- What internal nutrient set is mandatory for version 1 reporting?
- Should reminders be fully server-driven, client-scheduled, or hybrid?

## 23. One-Sentence Technical Recommendation

Use Flutter + FastAPI + PostgreSQL + Redis + Firebase notifications + USDA FoodData Central + Open Food Facts + ML Kit for the strongest free-first implementation path.
