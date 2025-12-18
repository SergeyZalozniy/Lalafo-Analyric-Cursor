# Lalafo Event Modeling Taxonomy and Format

This document outlines the standard taxonomy format and mandatory procedure for defining and logging user events across the Lalafo platform clients (`android`, `ios`, `web`, `web-mobile`) for system tracking and metric aggregation.

## 1. Core Event Taxonomy Structure

Every event tracked by the system must adhere to the standard technical taxonomy structure.

### JSON Format

The event structure consists of six mandatory components plus the optional `event_details` object,:

```json
{
"client": "...",      // Platform sending the event
"screen": "...",      // Screen where the action occurred
"component": "...",   // Functional module involved
"section": "...",     // Specific area within the screen/component
"element": "...",     // Specific interactive element
"action": "...",      // User interaction performed
"event_details": {...} // Structured metadata (e.g., status, price)
}
```

### Concatenated Format (Example)

Events are often logged in a concatenated format: `client|screen|component|section|element|action`,.

**Example:** A user selecting the app language on the settings screen:
`web|language|language|settings|field|select`

## 2. Event Modeling Mandate

When defining a new event structure, the moderator (analyst) must **strictly follow** the process outlined below, ensuring consistency by prioritizing existing terms in the libraries,.

1.  **Library Priority:** Always refer to the predefined libraries first when forming an event taxonomy.
2.  **Justification for New Units:** If a corresponding element is not found in the established libraries (for `component`, `action`, `section`, `screen`, or `element`), a new unit must be proposed along with justification.

## 3. Taxonomy Libraries (Field Definitions)

The following tables define the available values for each primary field used in the Lalafo event taxonomy.

### Client Options

These specify the platforms for which product design must be uploaded for modeling.

| Value |
| :--- |
| **`android`** |
| **`ios`** |
| **`web`** |
| **`web-mobile`** |

### Screen Library

Describes the specific page or interface where the event is observed.

| Value | Description (English) |
| :--- | :--- |
| `ad` | Screen for viewing a specific ad, including details and seller information. |
| `archive` | Ads archive page screen. |
| `auto_replenishment` | Auto-replenishment settings screen. |
| `chat_list` | Screen showing a list of all user chats. |
| `edit_ad` | Screen for editing an existing ad. |
| `favorites` | Screen for viewing the user's favorite ads. |
| `filters` | Screen for applying search filters to refine results. |
| `home` | The main screen of the app, showing categories, recommendations, and navigation options. |
| `language` | Screen for selecting the app's language. |
| `listing` | Screen displaying a list of ads based on selected categories or search criteria. |
| `login` | Screen for user login via email, phone, or social networks. |
| `my_profile` | User's profile screen with options to view or edit personal information. |
| `notifications` | Screen displaying notifications and alerts for the user. |
| `payment` | Screen for handling payments, including selecting a payment method. |
| `posting` | Screen for creating a new ad, including adding photos and descriptions. |
| `registration` | Screen for user registration, including input fields for creating an account. |
| `settings` | Screen for managing user settings, such as notifications and language preferences. |
| `sms_validation` | Screen for SMS verification. |
| `splash` | The initial screen displayed when the app is launched. |
| `user_profile` | Screen displaying another user's profile, including their ads and details. |
| `wallet` | Wallet top-up screen. |
| *... and many more listed in source* | |

### Component Library

Defines the functional module or high-level logical area responsible for the event.

| Value | Description (English) |
| :--- | :--- |
| `ad` | Responsible for the list of actions on the advertisement, deactivation, editing, and deletion. |
| `authorization` | Handles user authorization, including login via social networks, email, or phone. |
| `chat` | Displays chat between buyer and seller, including message and media file exchange. |
| `deactivate` | Handles ad deletion or deactivation. |
| `edit_profile` | Allows the user to edit their profile, including name, profile picture, and other personal details. |
| `favorites` | Shows the user's list of favorite ads with options to view or remove them. |
| `header` | Component responsible for navigation and top elements. |
| `listing` | Displays the ad list by categories or search query, with interaction options. |
| `loyalty_system` | Functionality responsible for the loyalty system features, including onboarding and purchasing. |
| `payment` | Handles payment method selection, confirmation, and status updates. |
| `post` | Used for the entire ad creation process: photo selection, description entry, category selection, and publishing. |
| `search` | Ad search functionality, including query input, filter selection, and category application. |
| `settings` | User settings section: language, notifications, security. |
| `vas` | Additional ad services like promotion (VIP, raising in the list). |
| `wallet` | Functionality responsible for wallet management. |
| *... and many more listed in source* | |

### Section Library

Defines the distinct area or sub-group within the screen or component.

| Value | Description (English) |
| :--- | :--- |
| `ads_publication` | Related to editing ads before publication via AI posting. |
| `basic` | Section for basic categories or default settings. |
| `camera` | Section for capturing photos using the device's camera. |
| `description` | Section for adding descriptions to ads. |
| `email_phone` | Section for login or registration using email or phone number. |
| `feed` | Section for displaying a feed of ads or content. |
| `gallery` | Section for selecting photos from the device's gallery. |
| `header` | Section for headers or top navigation elements. |
| `location` | Section for selecting or setting a location. |
| `price` | Section for entering or selecting price details. |
| `publish` | Section for publishing ads. |
| `recovery` | Section for password recovery process. |
| `social` | Section for social media integration, such as login via social networks. |
| `tab_bar` | Section containing bottom navigation tabs for switching between key application sections. |
| `vas` | Section for selecting value-added services, such as promotions. |
| *... and many more listed in source* | |

### Element Library

Defines the specific interactive UI item that the user touches or views.

| Value | Description (English) |
| :--- | :--- |
| `ad` | An element representing an advertisement. |
| `banner` | A graphical banner, often used for promotions or important messages. |
| `button` | A clickable button element, often used for actions like submit, close, or navigate. |
| `category` | Element used during posting for selecting the category of an ad. |
| `dropdown` | A dropdown menu for selecting one option from a list. |
| `empty_results` | Element displayed when search results are empty,. |
| `field` | An input field for entering text or data. |
| `icon` | A small graphical representation, often used as a shortcut for an action. |
| `map` | A map element for showing locations or navigation. |
| `photo` | An element representing a photo, often used for uploading or selecting images. |
| `price` | Element used to input or display ad price. |
| `tab_bar` | A navigation bar for switching between different tabs or sections. |
| `text_link` | A clickable text link, often redirecting to another page or action. |
| *... and many more listed in source* | |

### Action Library

Defines the measurable user interaction performed on the element.

| Value | Description (English) |
| :--- | :--- |
| `activate` | User activates a feature, service, or item, such as a paid promotion. |
| `add` | User adds a new item, such as a photo or an ad. |
| `apply` | User applies a filter or a specific setting in the app. |
| `call` | User initiates a phone call to the contact provided in an ad. |
| `deactivate` | User deactivates a feature, service, or item, such as an ad. |
| `delete` | User removes an item, such as an ad or a photo. |
| `edit` | User modifies or updates an existing item. |
| `input` | User provides input, such as typing in a text field. |
| `open` | User opens an element, such as a screen, menu, or ad. |
| `select` | Selection of an option, value, or item (e.g., dropdown, category). |
| `send_message` | User sends a message via chat or contact form. |
| `share` | User shares an ad or content via external platforms. |
| `tap` | User interaction with an element via a single tap (e.g., button, icon). |
| `view` | Action triggered when a user views an element, screen, or component in the app. |
| *... and many more listed in source* | |

### `event_details` Metadata Keys

Used to capture detailed context, transactional status, or values related to the event.

| Key | Data Type | Description (English) |
| :--- | :--- | :--- |
| **`status`** | `string` | Indicates the status of an action (1=success; 2=error group). |
| **`error_body`** | `string` | Provides details about an error that occurred during the action. |
| **`price`** | `float` | Represents the price associated with an ad or item. |
| **`category_id`** | `integer` | Identifies the category to which an item or action belongs. |
| **`query`** | `string` | The search query entered by the user. |
| **`location`** | `string` | Indicates the location associated with an event, such as ad posting. |
| **`mobile`** | `string` | Represents the mobile number provided or involved in the event. |
| **`timestamp`** | `datetime` | The exact date and time when the event occurred. |
| **`last_screen`** | `string` | Represents the last screen the user was on before the current event. |
| **`last_action`** | `string` | Represents the last action the user performed before the current event. |
| *... and many more listed in source* | |
