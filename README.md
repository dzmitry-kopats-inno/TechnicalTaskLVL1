# Technical Task Level 1

## Task Description
Create an iOS application that contains two screens:

1. **First Screen:**
   - Displays a list of Users from the CoreData storage.
   - Allows deleting a User from the database.
2. **Second Screen:**
   - Allows creating a new user locally.
   - Updates the list of users after creation.

## Business Rules

1. **User List Rules:**
   - The user list should be sorted by names in ascending order (case-insensitive).
   - Emails of users must be unique.
   - Display an error if a new user is created with an already existing email.
2. **Data Fetching:**
   - Fetch the user list from the API when:
     - The app is launched.
     - Internet connection is restored after offline mode.
     - "Pull to refresh" functionality is used.
   - If the API response contains users not in the database, insert them into CoreData.
   - Locally created users must not be deleted after updates from the API response.
3. **Offline Mode:**
   - If the device is offline, display info from CoreData.
   - Show a banner with the message: "No internet connection. You’re in Offline mode."
   - When the connection is restored, fetch updates from the API and close the banner automatically.
4. **UI Behavior:**
   - Updates to the user list should be animated.
   - The app should navigate to the first screen automatically on launch.
   - Email input on the second screen should handle basic email validation.

## Project Requirements

- **Database Layer:** Use the native CoreData framework.
- **Architectural Pattern:** Choose any suitable one.
- **Reactive Approach:** Use RxSwift or Combine (strongly recommended).
- **iOS Version:** Target iOS 15.0 or higher.
- **UI Framework:** Use UIKit.
- **Screen Size Support:** UI should adapt to different screen sizes.
- **Programming Language:** Swift 5.0+.
- **Version Control:**
  - Use Git for version control.
  - Create PRs to demonstrate your Git workflow.
  - Final PR should target the `main` (or `master`) branch.
  - Provide a link to the final PR for review.
- **Third-Party Libraries:** You may use any third-party libraries as needed.
- **Design Requirements:** No special design requirements, but the functionality and UI will be reviewed.

## Submissions and Starting Point

1. **Fork the Repository:**
   - Use the provided repository as the starting point.
   - Repository: [TechnicalTaskLVL1](https://github.com/ValeryVasilevich/TechnicalTaskLVL1)
2. **Submit Your Work:**
   - Use Git and PRs to show your progress.
   - Ensure all submission steps are followed as described.

## Resources

- **UI Example:** [UI Mockup](https://drive.google.com/file/d/1GBrRLzci-BFrBmrslZmqmvl4VoqcLYhN/view?usp=sharing)
- **API Endpoint:** [JSONPlaceholder API](https://jsonplaceholder.typicode.com/users)
