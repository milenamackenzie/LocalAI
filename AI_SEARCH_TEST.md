## AI Search Functionality Test Guide

### Test Steps:

1. **Launch the App**
   - Run the app on Windows
   - Login with: test@test.com / Test123!

2. **Test Basic AI Search**
   - In the prompt bar, type: "coffee shop with wifi"
   - Click the green arrow button
   - Expected: Loading overlay appears, then pins appear on map
   - Yellow pins = Social media popular locations
   - Green pins = Regular matching locations

3. **Test Different Search Types**
   - Try: "restaurant for dinner"
   - Try: "park with good views"
   - Try: "bar with live music"
   - Each should show relevant colored pins

4. **Test Bookmark Functionality**
   - Click history button (next to prompt bar)
   - Click bookmark icon next to any search
   - Go to Profile → Chat History
   - Verify bookmarked search appears

### Expected Results:
- ✅ No navigation away from map page
- ✅ Loading indicator appears during search
- ✅ Colored pins appear (yellow for social media popular, green for regular)
- ✅ Pins are geographically relevant to search
- ✅ Bookmark functionality still works
- ✅ Error handling shows messages instead of crashes

### API Note:
Currently using mock data for demonstration. To connect to real APIs:
1. Replace `_mistralApiKey` with actual Mistral AI API key
2. Configure OpenStreetMap API rate limits if needed
3. Add social media API keys for Twitter, Instagram, etc.

### Troubleshooting:
- If pins don't appear: Check console logs for API errors
- If app crashes: Check Dio HTTP client configuration
- If search is slow: Check network connectivity and API rate limits