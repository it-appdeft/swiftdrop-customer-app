# Customer Mobile App – Milestones

## Milestone 1 — Discovery Module

### Goal
Enable users to discover restaurants and food options based on location and preferences.

### Features

#### 1. Home Screen
- Detect and display user location
- Location-based restaurant recommendations
- Dynamic promotional banners
- Food categories listing
- Quick navigation sections
- Pull-to-refresh support

**Deliverables**
- Home UI completed
- API integration
- Location permission handling
- Loading & empty states

---

#### 2. Search
- Search restaurants
- Search dishes
- Recent searches
- Search suggestions
- No results handling

**Deliverables**
- Search UI
- Debounced API calls
- Search history

---

#### 3. Restaurant Listing
- Restaurant cards
- Filters
- Sorting options
- Promoted restaurants section
- Infinite scrolling / pagination

**Filters**
- Rating
- Delivery time
- Distance
- Cuisine
- Price range

**Sorting**
- Recommended
- Delivery Time
- Rating
- Distance

**Deliverables**
- Listing screen
- Filter modal
- Pagination support

---

#### 4. Restaurant Detail Page
- Restaurant information
- Opening hours
- Ratings & reviews
- Delivery details
- Menu categories
- Restaurant banners
- CTA for ordering

**Deliverables**
- Detail screen
- API integration
- Menu navigation

---

## Milestone 2 — Ordering Module

### Goal
Allow users to browse menus and complete orders seamlessly.

### Features

#### 5. Menu Viewing
- Category-based menu display
- Dish details
- Item customization
- Variants support
- Add-ons
- Quantity selector

**Deliverables**
- Menu screen
- Variant selection
- Price calculation

---

#### 6. Cart Management
- Add/remove items
- Edit customization
- Quantity updates
- Cart persistence
- Coupon placeholder

**Deliverables**
- Cart screen
- Local cart state
- API sync

---

#### 7. Checkout Process
- Checkout validation
- Delivery instructions
- Payment preparation
- Order confirmation flow

**Deliverables**
- Checkout screen
- Validation handling

---

#### 8. Address Selection
- Saved addresses
- Add new address
- Edit/delete address
- Current location
- Address validation

**Deliverables**
- Address management
- Maps integration

---

#### 9. Order Summary & Validation
- Order items review
- Delivery fee
- Tax calculation
- Total amount
- Validation before placing order

**Validation Rules**
- Address selected
- Cart not empty
- Restaurant availability
- Item availability

**Deliverables**
- Summary screen
- Validation flow
- Final order submission

---

# Success Criteria

- Smooth navigation across modules
- Responsive UI
- API integration completed
- Error handling implemented
- Analytics events tracked
- QA tested before release

---

# Estimated Release Flow

Milestone 1 → Discovery → QA → Release  
Milestone 2 → Ordering → QA → Release