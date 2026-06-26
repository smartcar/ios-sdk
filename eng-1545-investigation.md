# ENG-1545 Investigation: iOS SDK returns nil userId

**Linear:** https://linear.app/smartcar/issue/ENG-1545/connect-ios-sdk-returns-nil-userid-user-id-lost-in-webview-handoff
**Customer:** ev.energy
**Priority:** High
**Assignee:** Thach Do

---

## Summary

iOS `SmartcarAuth` 6.3.1 returns `userId = nil` in the `completionHandler`, even though
`connect-backend POST /oauth/grant` includes `user_id` in `exitRedirect`. Android (same app,
env, scopes) returns it correctly.

---

## Evidence (Observe dataset 42525077, app `9daa9840-ccad-4a03-ab4d-5222da30960e`, BMW simulated)

| Platform | Timestamp | exitRedirect | userId received? | requestId |
|---|---|---|---|---|
| iOS (iPhone OS 18_7) | 2026-06-25T07:53:09Z | `sc9daa9840-…://exchange?code=dbbe1a26…&user_id=8b421954-…` | ❌ nil | `d70cb8e5-30ae-4260-8cd7-533d27d1c7dd` |
| Android (Android 16 … wv) | 2026-06-23T08:24:38Z | `…&user_id=47a66c7f-…` | ✅ received | `7788b094-0ed4-461e-b598-c1fc868c695c` |

---

## iOS Connect flow (step-by-step)

```
SmartcarAuth.launchAuthFlow(url:, viewController:)
  └─ presents ConnectController (WKWebView)
       └─ loads connect.smartcar.com/oauth/authorize?...
            └─ user selects OEM (e.g., BMW)
                 └─ Connect JS calls SmartcarSDK.sendMessage({ authorizeURL, interceptPrefix })
                      └─ OAuthCapture.userContentController receives message
                           └─ starts ASWebAuthenticationSession(url: oemAuthURL, callbackURLScheme: ...)
                                └─ user completes OEM login
                                     └─ OAuthCapture.webAuthSessionCompletion(callbackURL: oemCallback)
                                          └─ sends SmartcarSDKResponse event to Connect JS
                                               { returnUri: "bmwcallback://..." }
                                                    └─ Connect JS calls POST /oauth/grant
                                                         └─ server returns exitRedirect with user_id  ✅
                                                              └─ Connect JS navigates webview to exitRedirect  ← loss point
                                                                   └─ ConnectController.webView(_:decidePolicyFor:)
                                                                        intercepts when host == redirectUriHost
                                                                             └─ handleCallback(url)  ← user_id absent
```

---

## SDK code analysis

The SDK parser is correct. `handleCallback` in [SmartcarAuth.swift:173](SmartcarAuth/SmartcarAuth.swift#L173) correctly reads `user_id`:

```swift
let userId = query.filter({$0.name == "user_id"}).first?.value
// ...
return self.completionHandler(code, queryState, virtualKeyUrl, userId, nil)
```

This was shipped in commit `abc0cc3 feat: include user_id on redirect` (ios-sdk#100, SDK 6.3.0).
The SDK is fine — it parses `user_id` when it's present in the URL.

---

## Root cause

**The loss is in the Connect frontend JS (hosted on Netlify) on the iOS webview exit path.**

The server's `/oauth/grant` response includes `user_id` in `exitRedirect` — confirmed by Observe
logs. But the Connect frontend JS does not forward `user_id` when navigating the webview to the
exit redirect URL. This is a Connect frontend code issue, not a caching issue.

**Why Android works:** Android intercepts the OEM callback URL at the OS level via intent filters
/ custom URL scheme, on a different code path in Connect that correctly passes through the full
`exitRedirect` including `user_id`.

**Note on ENG-23:** The Linear ticket references ENG-23 which mentioned a CloudFront cache problem,
but the Connect frontend is hosted on Netlify, not CloudFront. The prior ENG-23 fix likely patched
the JS code itself; the regression here means the iOS webview exit path is still (or again) not
forwarding `user_id`.

---

## What is NOT the issue

- The iOS SDK's `handleCallback` parser — confirmed correct
- The connect-backend `/oauth/grant` response — confirmed includes `user_id`
- The `OAuthCapture` → Connect JS handoff — this returns the OEM callback URL (correct)

---

## Proposed fix

1. **Confirm client-side:** log the URL received in `handleCallback` for an iOS session — expect
   `code` present, `user_id` absent.
2. **Fix Connect frontend (Netlify):** ensure the iOS webview exit path forwards `user_id` from
   the server's `exitRedirect` when navigating the webview to the final redirect URL.

## Customer workaround (interim)

Exchange `code` → `GET /v2.0/user` to retrieve the same `user_id`.

---

## Related

- ENG-23: Frontend SDKs to attach userId in redirect (original fix)
- EXP-1534: Add userId to connect redirect URL (server-side)
- ios-sdk#100: SDK-side `user_id` parsing (shipped 6.3.0)
