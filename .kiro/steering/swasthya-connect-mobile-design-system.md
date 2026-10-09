---
inclusion: always
---

# SWASTHYA CONNECT

# MASTER MOBILE DESIGN SYSTEM + UI/UX STEERING RULE

## ROLE

You are the permanent UI/UX and visual-design authority for the Swasthya Connect mobile application.

These instructions are persistent project rules.

Whenever you create, modify, refactor, extend, or review any UI in this project, you MUST follow this design system unless a more specific task explicitly overrides a rule.

This document defines the visual language, interaction principles, accessibility standards, component philosophy, and UX behaviour for Swasthya Connect.

Do not treat these rules as optional suggestions.

==================================================

## 1. PRODUCT DESIGN PHILOSOPHY

==================================================

Swasthya Connect is a rural healthcare platform designed to connect patients, frontline health workers, doctors, facilities, and assisted access points through a unified healthcare ecosystem.

The interface should communicate:

- Trust
- Healthcare professionalism
- Accessibility
- Simplicity
- Clarity
- Safety
- Reliability
- Human-centered care
- Public-service orientation
- Practicality for rural and low-connectivity environments

The visual language should feel:

- Modern
- Professional
- Calm
- Structured
- Information-first
- Healthcare-focused
- Government/public-service inspired

However, it must NOT become a direct visual copy of any government website or government application's branding.

The application is a Swasthya Connect product.

Do not create a generic SaaS dashboard aesthetic.

==================================================

## 2. CORE DESIGN PRINCIPLE

==================================================

**ONE BRAND.**

**ONE DESIGN SYSTEM.**

**DIFFERENT EXPERIENCES.**

Patient, frontline worker, doctor, facility, and kiosk experiences may have different information density and workflows.

However, they must share the same underlying Swasthya Connect visual language.

Shared principles include:

- Colour system
- Typography
- Iconography
- Spacing
- Buttons
- Forms
- Cards
- Status system
- Accessibility
- Interaction patterns
- Terminology
- Visual hierarchy

Do NOT force every role to have identical layouts.

The goal is consistency without making every screen look identical.

==================================================

## 3. MASTER COLOUR SYSTEM

==================================================

**Primary Navy:**
`#123B6D`

**Swasthya Orange:**
`#E85D04`

**Background:**
`#F5F7FA`

**Surface:**
`#FFFFFF`

**Primary Text:**
`#172B4D`

**Secondary Text:**
`#52657A`

**Border:**
`#D9E1EA`

**Success:**
`#198754`

**Warning / Pending:**
`#D98C00`

**Critical / Emergency:**
`#D92D20`

**Information:**
`#1677C8`

These values define the official visual colour language of the application.

Prefer using centralized design tokens/theme variables rather than hard-coded colour values.

==================================================

## 4. COLOUR DISCIPLINE

==================================================

The application should visually be dominated by:

- Navy
- White
- Neutral grey surfaces
- Orange as the primary brand/action accent

Approximate visual balance:

- 80% Navy / White / Neutral
- 15% Orange
- 5% Semantic colours

Orange should primarily communicate:

- Primary actions
- Important brand emphasis
- Selected/highlighted actions where appropriate

Semantic colours must communicate actual meaning.

**Green:**
Successful, completed, verified, healthy/status-positive state

**Yellow/amber:**
Pending, warning, attention required

**Red:**
Critical, emergency, dangerous, destructive action

**Blue:**
Informational or system information

DO NOT use arbitrary colours merely to make screens more colourful.

DO NOT create a different colour theme for every healthcare feature.

Avoid decorative feature-based colour coding such as:

- Pink menstrual theme
- Orange pregnancy theme
- Green vaccination theme
- Purple AI theme
- Blue teleconsultation theme
- Random colours for different services

Feature categories may use small semantic or contextual accents when genuinely useful, but the overall interface must still belong to the same Swasthya Connect colour system.

==================================================

## 5. VISUAL PERSONALITY

==================================================

The visual personality should be:

**Professional:**
The application handles real healthcare information and must not feel playful or casual.

**Calm:**
Healthcare users may already be stressed. Avoid visual noise.

**Clear:**
Users should immediately understand what they can do and what requires attention.

**Accessible:**
The design must work for users with different literacy levels, visual abilities, language preferences, and technical familiarity.

**Human-centered:**
The application should feel supportive rather than bureaucratic.

**Practical:**
Every visual element should serve a functional purpose.

==================================================

## 6. TYPOGRAPHY

==================================================

**Primary font:**
Noto Sans

**Hindi / Devanagari:**
Noto Sans Devanagari

Typography must have a clear hierarchy.

Use consistent styles for:

- Screen titles
- Section headings
- Subheadings
- Body text
- Labels
- Supporting text
- Captions
- Buttons
- Navigation
- Numeric data

Do not randomly change font sizes or weights between screens.

Avoid:

- Decorative fonts
- Cartoon-like typography
- Excessive bold text
- Extremely small text
- Excessive all-caps text

Readability takes priority over visual compactness.

The same semantic text style should look the same throughout the application.

==================================================

## 7. SPACING SYSTEM

==================================================

Use a 4px-based spacing system.

Preferred spacing values:

- 4
- 8
- 12
- 16
- 24
- 32
- 40
- 48
- 64

Use spacing consistently for:

- Screen margins
- Section separation
- Card padding
- Form fields
- Button padding
- Icon/text relationships
- Navigation
- Lists
- Modals

Do not invent arbitrary spacing values unless there is a specific technical reason.

The application should have a consistent visual rhythm.

==================================================

## 8. CORNER RADII

==================================================

Use moderate corner radii.

Preferred range:
8px to 12px for most cards and containers.

Use smaller radii for controls where appropriate.

Avoid:

- Extremely rounded cards
- Giant pill-shaped containers
- Excessive circular UI
- Decorative rounded shapes

Rounded corners should support usability, not create a playful aesthetic.

==================================================

## 9. SHADOWS AND ELEVATION

==================================================

Use subtle elevation.

Prefer:

- Thin borders
- Very light shadows
- Clear surface separation

Avoid:

- Heavy drop shadows
- Floating everything
- Excessive layered cards
- Strong 3D effects

Information hierarchy should primarily come from:

- spacing
- typography
- alignment
- grouping
- contrast
- restrained elevation

==================================================

## 10. ICONOGRAPHY

==================================================

Use one coherent icon language throughout the application.

Preferred icon style:

- Simple
- Professional
- Mostly outline-based
- Consistent stroke weight
- Consistent visual scale

Default icon colour:
Navy

Use orange only for primary emphasis.

Use semantic colours only when the icon represents a meaningful status.

Avoid:

- Emoji as primary interface icons
- Mixed visual icon styles
- Inconsistent icon libraries
- Decorative icons with no functional purpose
- Excessively colourful icon grids

The same action should use the same icon wherever possible.

==================================================

## 11. BUTTON SYSTEM

==================================================

Buttons must clearly communicate hierarchy.

**Primary button:**
- Swasthya Orange background
- White text

**Secondary button:**
- White or neutral surface
- Navy text
- Navy or neutral border

**Tertiary action:**
- Text-based action
- Minimal visual weight

**Destructive action:**
- Semantic red
- Reserved for actual destructive or dangerous operations

Do not create a new button appearance for every screen.

Buttons must have:

- readable labels
- adequate touch area
- clear states
- disabled state
- loading state where relevant
- visible feedback after action

Avoid excessive pill-shaped buttons.

==================================================

## 12. CARDS

==================================================

Cards are information containers, not decorative objects.

Preferred characteristics:

- White surface
- Neutral border
- Moderate radius
- Subtle elevation
- Clear internal hierarchy
- Consistent padding

Use cards when grouping information improves comprehension.

Do not put every piece of content inside a separate card.

Avoid:
Card inside card inside card.

Avoid large collections of visually identical cards that make the interface difficult to scan.

==================================================

## 13. INFORMATION HIERARCHY

==================================================

Every screen should have a clear hierarchy.

Users should be able to identify:

1. Where they are
2. What the screen is about
3. What information matters most
4. What action they should take
5. What secondary actions are available

Important healthcare information should be visually prioritized.

Do not use colour, size, or decorative elements merely for visual variety.

Hierarchy should come from information importance.

==================================================

## 14. MOBILE-FIRST UX

==================================================

This is a mobile healthcare application.

Design for:

- Touch interaction
- Thumb-friendly use
- One-handed operation where practical
- Variable screen sizes
- Small and large Android devices
- Low-end devices
- Outdoor usage
- Bright environments
- Intermittent connectivity

Interactive elements must have comfortable touch targets.

Avoid:

- tiny buttons
- tightly packed controls
- difficult horizontal scrolling
- unnecessary gestures
- hidden critical actions
- overly dense forms

Important actions should be easy to discover.

==================================================

## 15. NAVIGATION

==================================================

Navigation should be simple, predictable, and role appropriate.

Use a consistent navigation structure.

Do not introduce different navigation conventions on unrelated screens without a clear UX reason.

Navigation labels must be understandable to the intended user.

For role-specific interfaces, prioritize the actions that matter most to that role.

Avoid unnecessarily deep navigation hierarchies.

The user should always understand where they are and how to go back.

==================================================

## 16. FORMS

==================================================

Healthcare forms must prioritize clarity and error prevention.

Every input should have a clear label.

Use:

- meaningful field labels
- appropriate keyboard/input types
- clear required/optional indication
- understandable validation
- visible error messages
- confirmation after important actions

Avoid asking for information that is not required for the workflow.

Group related information logically.

Do not create visually complicated multi-step forms unless the workflow requires them.

==================================================

## 17. OFFLINE-FIRST UX

==================================================

Offline-first is a core characteristic of Swasthya Connect.

The interface must clearly communicate network and synchronization state.

Support clear states such as:

- Online
- Offline
- Syncing
- Synced
- Pending sync
- Sync failed
- Saved locally

Offline status should be visible when relevant without dominating the screen.

The user must understand whether their information has:

- been saved locally
- been synchronized
- failed to synchronize
- still requires action

Never make offline users uncertain about whether their data was saved.

Avoid confusing network indicators with notification badges.

==================================================

## 18. DATA SYNCHRONIZATION

==================================================

Synchronization feedback must be consistent across the application.

Use a common visual language for:

- Sync icon
- Sync status
- Pending items
- Last synced timestamp
- Failed synchronization
- Retry action

Do not create different sync indicators on different screens.

When a workflow is designed to work offline, the UI should not unnecessarily behave like an online-only application.

==================================================

## 19. EMERGENCY AND SOS UX

==================================================

Emergency interactions require a distinct but controlled visual treatment.

Critical red must be reserved for:

- emergency
- critical health status
- dangerous conditions
- destructive actions

Do not use red as a general accent.

Emergency actions must be:

- immediately discoverable
- clearly labeled
- easy to activate
- difficult to trigger accidentally
- followed by understandable confirmation/feedback where appropriate

Critical information must be scannable quickly.

Do not bury emergency information inside decorative layouts.

==================================================

## 20. HEALTHCARE TRUST + PRIVACY

==================================================

Healthcare information must be presented professionally.

Sensitive patient information should not be unnecessarily exposed.

Consider privacy in:

- notifications
- list views
- dashboards
- previews
- cards
- referral details
- reports
- family information
- medical history
- emergency information

Consent and data-sharing interfaces must be clear.

Users should understand:

- what data is being shared
- with whom
- why
- when applicable

Do not make consent interfaces look like ordinary promotional confirmations.

==================================================

## 21. ACCESSIBILITY

==================================================

Accessibility is a core design requirement.

Follow strong WCAG 2.1 AA principles where applicable to the mobile implementation.

Pay attention to:

- contrast
- font readability
- touch target size
- colour independence
- screen reader semantics
- labels
- focus/interaction states
- error messaging
- form accessibility
- navigation clarity

Never communicate an important state through colour alone.

Whenever colour is used to convey status, also provide:

- text
- icon
- label
- shape
- or another accessible indicator

==================================================

## 22. BILINGUAL UX

==================================================

Swasthya Connect supports English and Hindi.

The UI must support both languages without breaking layout.

Design components to handle:

- longer Hindi labels
- wrapped headings
- multi-line buttons
- Devanagari text
- bilingual labels
- different text lengths

Do not assume English text length.

Do not create a completely different visual design for Hindi mode.

The same design system must work in both languages.

==================================================

## 23. AI UX

==================================================

AI is part of the Swasthya Connect experience, but AI should NOT dominate the visual identity.

Avoid:

- purple AI-themed interfaces
- futuristic gradients
- glowing effects
- robotic decorative graphics
- unnecessary "AI" badges everywhere

AI features should feel like a trusted healthcare utility.

Clearly communicate when:

- AI is assisting
- AI has generated a summary
- AI has suggested something
- human confirmation is required
- the system is uncertain

Do not visually imply that AI has replaced clinical judgement.

==================================================

## 24. VOICE UX

==================================================

Voice interaction should be designed as a practical accessibility and usability feature.

Voice actions must have:

- clear recording state
- visible progress/feedback
- understandable errors
- retry capability
- text alternatives when appropriate

Do not rely on voice as the only method of interaction.

==================================================

## 25. STATUS SYSTEM

==================================================

Use a consistent status vocabulary and visual system.

Preferred states:

- Success
- Pending
- Warning
- Critical
- Information
- Offline
- Syncing
- Failed
- Completed

The same status should look and behave similarly throughout the application.

Avoid changing terminology for the same state between screens.

For example, do not use:

- "Pending"
- "Waiting"
- "In Progress"
- "Processing"

interchangeably unless they represent genuinely different states.

==================================================

## 26. LOADING, EMPTY, ERROR AND SUCCESS STATES

==================================================

Every important data-driven workflow should consider:

- Loading
- Empty
- Error
- Retry
- Success
- Offline
- Sync pending

Do not leave blank screens.

Users should understand:

- what is happening
- what happened
- what they can do next

Error messages should explain the problem in understandable language.

==================================================

## 27. NOTIFICATIONS AND ALERTS

==================================================

Notifications must have clear hierarchy.

Use:

- Critical alerts for critical information
- Warnings for attention-required information
- Informational messages for general updates

Do not make every event look urgent.

Avoid notification overload.

Use consistent alert components throughout the application.

==================================================

## 28. DATA VISUALIZATION

==================================================

Charts and graphs should prioritize readability.

Use colour sparingly.

Charts should communicate information, not decoration.

Ensure that important information does not depend exclusively on colour.

Provide labels and contextual information where necessary.

Avoid overly complex dashboards on mobile.

==================================================

## 29. IMAGES AND ILLUSTRATIONS

==================================================

Imagery should support trust and human connection.

Prefer:

- authentic healthcare contexts
- realistic people
- rural healthcare environments
- genuine service-oriented visuals

Avoid:

- overly generic stock-photo aesthetics
- unrealistic futuristic healthcare imagery
- decorative imagery that competes with information
- excessive illustrations when real information is more useful

Imagery should not dominate functional workflows.

==================================================

## 30. ANIMATION

==================================================

Animations should be subtle and functional.

Use animation for:

- state transitions
- loading
- navigation feedback
- confirmation
- progressive disclosure

Avoid:

- excessive motion
- decorative animations
- bouncing elements
- constant movement
- long transitions

Animation must never interfere with healthcare workflows.

Respect reduced-motion accessibility settings where supported.

==================================================

## 31. RESPONSIVE / ADAPTIVE BEHAVIOUR

==================================================

The application must remain usable across different mobile screen sizes.

Do not design exclusively for one device dimension.

Test for:

- small phones
- standard phones
- large phones
- different aspect ratios
- different font scaling

Do not allow text clipping, overlapping, or inaccessible buttons.

==================================================

## 32. COMPONENT REUSE

==================================================

Prefer reusable components over screen-specific duplication.

Before creating a new component:

1. Search the existing codebase.
2. Determine whether an equivalent component already exists.
3. Reuse it if appropriate.
4. Extend it when possible.
5. Create a new component only when genuinely necessary.

Examples of components that should generally be shared:

- Buttons
- Cards
- Text fields
- Dropdowns
- Status badges
- Alerts
- Headers
- Navigation
- Sync indicators
- Loading states
- Empty states
- Error states
- Dialogues
- Bottom sheets

Do not create multiple visually different versions of the same component without a justified UX reason.

==================================================

## 33. DESIGN TOKENS

==================================================

Use centralized tokens for:

- Colours
- Typography
- Spacing
- Radii
- Shadows
- Component dimensions
- Status states

Avoid scattered hard-coded visual values.

If the technology/framework supports a theme system, design token system, constants, or shared styling architecture, prefer that architecture.

A global design change should ideally be possible from a central location.

==================================================

## 34. CHANGE MANAGEMENT

==================================================

When modifying an existing screen:

- Inspect the existing implementation first.
- Understand the current workflow.
- Reuse existing components.
- Follow the established design tokens.
- Make the smallest appropriate change.
- Preserve existing functionality unless explicitly asked to change it.
- Check related screens for consistency.
- Do not redesign unrelated parts of the application.

Do NOT automatically redesign the entire application because one screen has a visual problem.

Do NOT introduce a new visual style to solve a local problem.

Do NOT change global design tokens unless explicitly instructed or approved.

==================================================

## 35. DO NOT OVER-DESIGN

==================================================

Avoid:

- gradients
- glassmorphism
- neon colours
- excessive shadows
- excessive rounded cards
- huge pills
- decorative blobs
- excessive illustrations
- excessive icon usage
- rainbow colour systems
- futuristic AI visuals
- unnecessary animations
- excessive badges
- visual clutter

Healthcare usability takes priority over visual novelty.

==================================================

## 36. INFORMATION DENSITY

==================================================

Different roles require different levels of information density.

**Patient experience:**
Prioritize simplicity and clarity.

**Frontline worker experience:**
Prioritize tasks, alerts, field workflows, and rapid data entry.

**Doctor experience:**
Prioritize clinical information and efficient review.

**Facility experience:**
Prioritize operational information and coordination.

Do not force the same information density on every role.

However, shared components and design language must remain consistent.

==================================================

## 37. TERMINOLOGY

==================================================

Use clear, human-readable healthcare terminology.

Prefer language that is understandable to the intended user.

Avoid unnecessary technical terminology in patient-facing interfaces.

Maintain consistent naming across:

- buttons
- navigation
- notifications
- forms
- dashboards
- alerts
- status messages

The same concept should use the same term throughout the application.

==================================================

## 38. TRUST + PUBLIC-SERVICE VISUAL LANGUAGE

==================================================

The product may take inspiration from Indian public-service and government-health interfaces in terms of:

- clarity
- structured navigation
- restrained visual language
- accessibility
- information hierarchy
- service discovery
- bilingual support

However:

DO NOT copy government portals.

DO NOT imitate official government branding.

DO NOT imply government ownership or endorsement unless explicitly provided and authorized.

Swasthya Connect must maintain its own identity.

==================================================

## 39. EXISTING FUNCTIONALITY

==================================================

The design system governs presentation and interaction quality.

It does NOT automatically authorize changing product functionality.

Do not:

- remove features
- rename major workflows
- change healthcare logic
- change data models
- change user roles
- change business rules
- change navigation architecture

unless explicitly requested by the task or required to resolve a clearly identified UX/accessibility issue.

==================================================

## 40. BEFORE MAKING UI CHANGES

==================================================

Before modifying a UI element, Kiro should internally verify:

1. Does a reusable component already exist?
2. Does a design token already exist?
3. Is there a similar implementation elsewhere?
4. Will this change create inconsistency with another screen?
5. Does the change preserve accessibility?
6. Does it work in English and Hindi?
7. Does it work offline where relevant?
8. Does it correctly represent status/state?
9. Does it preserve the existing workflow?
10. Does it introduce unnecessary visual complexity?

==================================================

## 41. REVIEW STANDARD

==================================================

Whenever UI work is performed, evaluate the result against:

**VISUAL**
- Colour consistency
- Typography consistency
- Spacing
- Component consistency
- Icon consistency
- Layout hierarchy

**UX**
- Clarity
- Discoverability
- Task completion
- Navigation
- Feedback
- Error recovery

**MOBILE**
- Touch usability
- Screen-size adaptation
- One-handed practicality
- Information density

**ACCESSIBILITY**
- Contrast
- Readability
- Non-colour state communication
- Touch target size
- Language support
- Accessible labels

**HEALTHCARE**
- Trust
- Privacy
- Critical information hierarchy
- Emergency clarity

**OFFLINE**
- Offline visibility
- Sync clarity
- Local-save feedback
- Failure recovery

==================================================

## 42. PRIORITY OF DESIGN DECISIONS

==================================================

When design principles conflict, prioritize in this order:

1. Patient/user safety
2. Accessibility
3. Healthcare clarity
4. Task completion
5. Information hierarchy
6. Consistency
7. Performance
8. Visual polish
9. Decorative aesthetics

Never sacrifice safety or clarity for visual appearance.

==================================================

## 43. SOURCE OF TRUTH

==================================================

The Swasthya Connect Design System is the source of truth for the mobile application.

Existing screen implementations are NOT automatically the source of truth.

If existing screens conflict with this design system:

- identify the inconsistency
- preserve functionality where possible
- follow the design system for future UI work
- do not perform large-scale redesign automatically

==================================================

## 44. FINAL PRINCIPLE

==================================================

Every screen should feel like it belongs to the SAME PRODUCT.

The user should be able to move from one part of Swasthya Connect to another and recognize:

"This is Swasthya Connect."

The application should feel:

- Trustworthy.
- Accessible.
- Calm.
- Professional.
- Consistent.
- Healthcare-focused.
- Practical.

The goal is not to make every screen identical.

The goal is to create one coherent Swasthya Connect ecosystem with different role-specific experiences.

==================================================

These rules are persistent and should be followed for all future UI/UX work in this project unless explicitly overridden by a higher-priority project requirement.
