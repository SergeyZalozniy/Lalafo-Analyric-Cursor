// Auto-generated tracking functions

static func trackMyAdBoostPhotoPostOnboardingView() {
    let eventDetails: EventDetails = EventDetails(
        screen: Event.Screen.myAd,
        section: Event.Section.boostPhoto,
        component: Event.Component.post,
        element: Event.Element.onboarding,
        action: Event.Action.view
    )
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
}

static func trackMyAdBoostPhotoPostButtonView(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
        screen: Event.Screen.myAd,
        section: Event.Section.boostPhoto,
        component: Event.Component.post,
        element: Event.Element.button,
        action: Event.Action.view,
        details: .defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
}

static func trackMyAdBoostPhotoPostButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
        screen: Event.Screen.myAd,
        section: Event.Section.boostPhoto,
        component: Event.Component.post,
        element: Event.Element.button,
        action: Event.Action.tap,
        details: .defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
}

static func trackMyAdGenerationPostPhotoBoostWaitingPopupView(advertisement: EventAdvertisementProtocol) {
    let eventDetails: EventDetails = EventDetails(
        screen: Event.Screen.myAd,
        section: Event.Section.generation,
        component: Event.Component.post,
        element: Event.Element.photoBoostWaitingPopup,
        action: Event.Action.view
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
}

static func trackMyAdGenerationPostPopupTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
        screen: Event.Screen.myAd,
        section: Event.Section.generation,
        component: Event.Component.post,
        element: Event.Element.popup,
        action: Event.Action.tap,
        details: .defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
}

static func trackAiPhotoEnhancementFollowupPopupPostButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
        screen: Event.Screen.aiPhotoEnhancementFollowup,
        section: Event.Section.popup,
        component: Event.Component.post,
        element: Event.Element.button,
        action: Event.Action.tap,
        details: .defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
}

