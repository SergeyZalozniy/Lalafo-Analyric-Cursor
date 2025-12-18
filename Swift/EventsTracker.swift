//
//  EventsTracker.swift
//  Lalafo
//
//  Created by Anton Ivashyna on 07/09/2017.
//  Copyright © 2017 Yallaclassified. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

final class EventFactory {
  static func event(for advertisement: EventAdvertisementProtocol? = nil, with eventDetails: EventDetails) -> EventModel {
    return EventModel(advertisement: advertisement, eventDetails: eventDetails)
  }
}

final class EventsTracker {
  // MARK: - Private properties
  private static let eventsService: EventsService = EventsService.shared

  static let debugKey = "com.lalafo.qa.tests.analytics.debug"
  static let adjDebugKey = "com.lalafo.qa.tests.analytics.adj"
  static let gaDebugKey = "com.lalafo.qa.tests.analytics.ga"
  static let iaDebugKey = "com.lalafo.qa.tests.analytics.ia"
  static let screenDebugKey = "com.lalafo.qa.tests.analytics.screen"
  static let intervalDebugKey = "com.lalafo.qa.tests.nps.interval"
  static let intervalRatingDebugKey = "com.lalafo.qa.tests.rating.interval"

  // MARK: - Private functions
  private static func debugTrackEvent(event: EventModel) {
    let toDebug: Bool = UserDefaults.standard.bool(forKey: debugKey)
    let toDebugGA: Bool = UserDefaults.standard.bool(forKey: gaDebugKey)
    let toDebugIA: Bool = UserDefaults.standard.bool(forKey: iaDebugKey)

    if toDebug {
      var debugTitles: [String] = []
      if toDebugGA { debugTitles.append(event.gaDebudInfo) }
      if toDebugIA { debugTitles.append(event.iaDebugInfo) }
      let joinedDebugTitles = debugTitles.joined(separator: "\n")
      if !joinedDebugTitles.isEmpty {
        LFDebugView.setDebugText(joinedDebugTitles)
      }
    }
#if !DEBUG
    if SettingsManager.shared.isTestEnvironment {
      if let json = event.toJSONString(prettyPrint: true) {
        let message = String(format: "AnalyticsLoggingInterceptor: %@ \n%@", event.name, json)
        LogAnalyticEvent(message)
      } else {
        let message = String(format: "AnalyticsLoggingInterceptor: %@", event.name)
        LogAnalyticEvent(message)
      }
    }
#endif
  }

  private static func debugTrackScreen(screen: Event.Screen) {
    let toDebug: Bool = UserDefaults.standard.bool(forKey: debugKey)
    let toDebugScreen: Bool = UserDefaults.standard.bool(forKey: screenDebugKey)

    if toDebug {
      var debugTitles: [String] = []
      if toDebugScreen { debugTitles.append(screen.name) }
      let joinedDebugTitles: String = debugTitles.joined(separator: "\n")
      if !joinedDebugTitles.isEmpty {
        LFDebugView.setDebugText(joinedDebugTitles)
      }
    }
  }

  // MARK: - Public functions
  static func trackEvent(event: EventModel) {
    guard event.isTrackable else { return }
    if let name = event.name {
      ModalCommunicationManager.shared.showModalCommunication(event: name)
      
      // Just use for debuging
      // _$l(name + "\n" + event.details.debugDescription + "\n")
    }
    debugTrackEvent(event: event)
    EventsService.trackEvent(event)
    GoogleAnalyticsService.trackEvent(event)
  }
  
  static func trackPushOpen(_ pushName: String) {
    EventsService.shared.trackPushOpen(pushName)
  }
  
  static func trackMessageButtonTap(_ aParameters: [String: Any]) {
    var parameters: [EventDetailsParameter] = []
    if let eventId = aParameters["event_id"] as? String {
      parameters.append(EventDetailsParameter(key: Constants.EventDetails.messageEventId,
                                              value: eventId))
    }
    
    if let actionType = aParameters["app_action_type"] as? String {
      parameters.append(EventDetailsParameter(key: Constants.EventDetails.messageAppActionType,
                                              value: actionType))
    }
      
    EventsService.shared.updateMessageButtonDetails(parameters)
  }
  
  static func updateMessageButtonDetails(eventId: String?, actionType: String?) {
    var parameters: [EventDetailsParameter] = []
    if let eventId = eventId {
      parameters.append(
        EventDetailsParameter(key: Constants.EventDetails.messageEventId, value: eventId)
      )
    }
    if let actionType = actionType {
      parameters.append(
        EventDetailsParameter(key: Constants.EventDetails.messageAppActionType, value: actionType)
      )
    }
    EventsService.shared.updateMessageButtonDetails(parameters)
  }

  static func trackScreenView(screen: Event.Screen) {
    debugTrackScreen(screen: screen)
    GoogleAnalyticsService.trackScreenView(screen: screen)
  }
  
  static func setCustomValue(_ value: Any, forKey key: String) {
    Crashlytics.crashlytics().setCustomValue(value, forKey: key)
  }
}

extension EventsTracker {
  
  // MARK: - Avertisement details
  
  /// open profile
  static func trackAdUserAdTextLinkTap(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.ad, section: Event.Section.user, element: Event.Element.textLink, action: Event.Action.tap, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackMyAdProAccountUpgradeProfileButtonTap(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.proAccount, section: Event.Section.upgradeProfile, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostRecommendationPhotoTextLinkView(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.recommendationPhoto, element: Event.Element.textLink, action: Event.Action.view)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostRecommendationDescriptionTextLinkView(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.recommendationDescription, element: Event.Element.textLink, action: Event.Action.view)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostRecommendationParamsTextLinkView(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.recommendationParams, element: Event.Element.textLink, action: Event.Action.view)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostRecommendationPhotoTextLinkTap(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.recommendationPhoto, element: Event.Element.textLink, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostRecommendationDescriptionTextLinkTap(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.recommendationDescription, element: Event.Element.textLink, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostRecommendationParamsTextLinkTap(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.recommendationParams, element: Event.Element.textLink, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostGalleryPhotoAdd(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.gallery, element: Event.Element.photo, action: Event.Action.add)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostDescriptionFieldApply(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.description, element: Event.Element.field, action: Event.Action.apply)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostPriceFieldApply(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.price, element: Event.Element.field, action: Event.Action.apply)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostCurrencyFieldApply(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.currency, element: Event.Element.field, action: Event.Action.apply)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostParamsFieldApply(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.params, element: Event.Element.field, action: Event.Action.apply)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostMobileFieldApply(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.mobile, element: Event.Element.field, action: Event.Action.apply)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostLocationFieldApply(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.location, element: Event.Element.field, action: Event.Action.apply)
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackEditAdPostMyAdFieldApply(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editAdvertisement, component: Event.Component.post, section: Event.Section.myAd, element: Event.Element.field, action: Event.Action.apply, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackAdStatisticsStatisticsInfoButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.statisticsInfo, section: Event.Section.statistics, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackStatisticsInfoInfoBlockButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.statistics, component: Event.Component.info, section: Event.Section.infoBlock, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackStatisticsComponentMetricsButtonTap(component: Event.Component) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.statistics, component: component, section: Event.Section.metrics, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackStatisticsPPVAdvertiseButtonButtonTap(_ section: Event.Section, advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.statistics, component: Event.Component.ppv, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackStatisticsPPVBPAdvertiseButtonButtonTap(_ section: Event.Section, advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.statistics, component: Event.Component.ppvBP, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Avertisement change
  /// change promotion budget
  static func trackMyAdPPVPPVUpdateButtonButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppv, section: Event.Section.ppvUpdateButton, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Activate
  static func trackAdActivateButtonTap(from screen: Event.Screen, advertisement: Advertisement) {
    var params: [EventDetailsParameter] = []
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ad, section: Event.Section.activate, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  /// Edit
  static func trackAdEditButtonTap(from screen: Event.Screen, advertisement: Advertisement) {
    var params: [EventDetailsParameter] = []
    params.append(contentsOf: advertisement.getEventDetails())
    
    if let campaignId = advertisement.campaigns.first?.id {
      params.append(EventDetailsParameter(key: Constants.EventDetails.campaignId,
                                          value: "\(campaignId)"))
    }
    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ad, section: Event.Section.editAd, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }

  /// Deactivate
  static func trackDeactivateDeactivateButtonTap(from screen: Event.Screen, advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    var params: [EventDetailsParameter] = parameters
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ad, section: Event.Section.deactivate, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  /// Delete
  static func trackAdDeleteButtonTap(from screen: Event.Screen, advertisement: Advertisement) {
    var params: [EventDetailsParameter] = []
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ad, section: Event.Section.delete, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    trackEvent(event: EventFactory.event(for: advertisement, with: eventDetails))
  }
  
  static func trackMyAdAdModerationLinkButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ad, section: Event.Section.moderationLink, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  // MARK: - Authorization

  /// Call Verification resend button tap
  static func trackCallValicationComponentResendCallButtonTap(component: Event.Component) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.callValidation, component: component, section: Event.Section.resendCall, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCallValidationComponentConfirmButtonTap(component: Event.Component, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.callValidation, component: component, section: Event.Section.confirm, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// SMS Verification resend button tap
  static func trackSMSValidationComponentResendSMSButtonTap(component: Event.Component, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.smsValidation, component: component, section: Event.Section.resendSMS, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackSMSValidationComponentConfirmButtonTap(component: Event.Component, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.smsValidation, component: component, section: Event.Section.confirm, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [sign_social] Sign up with social
  static func trackRegistrationAuthorizationSocialElementTap(_ element: Event.Element, label: String) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.registration, component: Event.Component.authorization, section: Event.Section.social, element: element, action: Event.Action.tap, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [sign_email_phone] Sign up with email and phone
  static func trackRegistrationAuthorizationWithEmailOrPhoneButtonTap(label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.registration, component: Event.Component.authorization, section: Event.Section.emailOrPhone, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [login_social] Login with social networks
  static func trackLoginAuthorizationSocialElementTap(_ element: Event.Element, label: String) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.login, component: Event.Component.authorization, section: Event.Section.social, element: element, action: Event.Action.tap, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [login_email_phone] Login with Email or phone
  static func trackLoginAuthorizationWithEmailOrPhoneButtonTap(label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.login, component: Event.Component.authorization, section: Event.Section.emailOrPhone, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.defined(label), details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [recover_password] Recover password
  static func trackLoginAuthorizationRecoveryButtonTap(label: String) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.login, component: Event.Component.authorization, section: Event.Section.recovery, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Authorization v2
  // Auth screen
  static func trackAuthorizationAuthorizationAuthorizationScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.authorization, component: Event.Component.authorization, section: Event.Section.authorization, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAuthorizationAuthorizationSectionButtonTap(_ section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.authorization, component: Event.Component.authorization, section: section, element: Event.Element.button, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAuthorizationLoginEmailButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.authorization, component: Event.Component.login, section: Event.Section.email, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAuthorizationAuthorizationSocialElementTap(_ element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.authorization, component: Event.Component.authorization, section: Event.Section.social, element: element, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // Sign up screen
  static func trackPhoneConfirmationRegistrationPhoneConfirmationScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.phoneConfirmation, component: Event.Component.registration, section: Event.Section.phoneConfirmation, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPhoneConfirmationRegistrationMobileButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.phoneConfirmation, component: Event.Component.registration, section: Event.Section.mobile, element: Event.Element.button, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPhoneConfirmationRegistrationSocialElementTap(_ element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.phoneConfirmation, component: Event.Component.registration, section: Event.Section.social, element: element, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPhoneConfirmationLoginSocialButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.phoneConfirmation, component: Event.Component.login, section: Event.Section.social, element: Event.Element.button, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // Sign In screen
  static func trackLoginLoginLoginScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.login, component: Event.Component.login, section: Event.Section.login, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoginRecoveryRecoveryPasswordButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.login, component: Event.Component.recovery, section: Event.Section.recoveryPassword, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoginLoginSectionButtonTap(_ section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.login, component: Event.Component.login, section: section, element: Event.Element.button, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // Forgot password
  static func trackRecoveryRecoverySectionButtonTap(_ section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.recovery, component: Event.Component.recovery, section: section, element: Event.Element.button, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCreatePasswordCreatePasswordAuthorizationScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.сreatePassword, component: Event.Component.сreatePassword, section: Event.Section.authorization, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCreatePasswordCreatePasswordAuthorizationButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.сreatePassword, component: Event.Component.сreatePassword, section: Event.Section.authorization, element: Event.Element.button, action: Event.Action.tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Verification
  static func trackPhoneConfirmationMobileVerificationOldUserScreenView() {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.phoneConfirmation,
          section: Event.Section.mobile,
          component: Event.Component.verificationOldUser,
          element: Event.Element.screen,
          action: Event.Action.view
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPhoneConfirmationPhoneConfirmationVerificationOldUserButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.phoneConfirmation,
          section: Event.Section.phoneConfirmation,
          component: Event.Component.verificationOldUser,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPhoneConfirmationCloseVerificationOldUserButtonTap() {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.phoneConfirmation,
          section: Event.Section.close,
          component: Event.Component.verificationOldUser,
          element: Event.Element.button,
          action: Event.Action.tap
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPhoneConfirmationVerificationOldUserNumberUpdateScreenView() {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.phoneConfirmation,
          section: Event.Section.verificationOldUser,
          component: Event.Component.numberUpdate,
          element: Event.Element.screen,
          action: Event.Action.view
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPhoneConfirmationConfirmNumberUpdateButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.phoneConfirmation,
          section: Event.Section.confirm,
          component: Event.Component.numberUpdate,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPhoneConfirmationCloseNumberUpdateButtonTap() {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.phoneConfirmation,
          section: Event.Section.close,
          component: Event.Component.numberUpdate,
          element: Event.Element.button,
          action: Event.Action.tap
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackSmsValidationConfirmComponentButtonTap(component: Event.Component) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.smsValidation,
          section: Event.Section.confirm,
          component: component,
          element: Event.Element.button,
          action: Event.Action.tap
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackSmsValidationResendSmsComponentButtonTap(component: Event.Component) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.smsValidation,
          section: Event.Section.resendSMS,
          component: component,
          element: Event.Element.button,
          action: Event.Action.tap
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }
  
  // MARK: - Service Fee
  static func trackScreenServiceFeeInfoSupplierButtonTap(screen: Event.Screen, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: screen,
          section: Event.Section.serviceFeeInfo,
          component: Event.Component.supplier,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackServiceFeeInfoGotItSupplierButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.serviceFeeInfo,
          section: Event.Section.gotIt,
          component: Event.Component.supplier,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackServiceFeeInfoLandingSupplierButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.serviceFeeInfo,
          section: Event.Section.landing,
          component: Event.Component.supplier,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackServiceFeeInfoPostingPostButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.serviceFeeInfo,
          section: Event.Section.posting,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }
  
  // MARK: - Images loading error
  static func trackScreenSectionImagePhotoError(advertisement: EventAdvertisementProtocol, screen: Event.Screen, section: Event.Section, url: URL?) {
    var parameters: [EventDetailsParameter] = []
    if let url = url?.absoluteString {
      parameters.append(EventDetailsParameter(key: Constants.EventDetails.imageUrl, value: url))
    }
    let eventDetails: EventDetails = EventDetails(
      screen: screen,
      section: section,
      component: Event.Component.image,
      element: Event.Element.photo,
      action: Event.Action.error,
      details: .defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Chat
  static func trackSaleChatFastMessageAddMessageButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.saleChat, component: Event.Component.fastMessage, section: Event.Section.addMessage, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackSaleChatContactChatButtonSendPreparedMessage() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.saleChat, component: Event.Component.contact, section: Event.Section.chat, element: Event.Element.button, action: Event.Action.sendPreparedMessage, label: Event.Label.defined(Constants.Analytics.Lalafo.Label.messageEachMessage))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackFastMesssageFastMessageAddFastMessageButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.fastMessage, component: Event.Component.fastMessage, section: Event.Section.addFastMessage, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  static func trackFastMesssageFastMessageSectionButtonTap(_ section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.fastMessage, component: Event.Component.fastMessage, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [open ulr in chat]
  static func trackScreenChatChatLinkTap(advertisement: EventAdvertisementProtocol?, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.chat, section: Event.Section.chat, element: Event.Element.link, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// [open_chat] Open o chat
  static func trackChatListChatOpen(advertisement: EventAdvertisementProtocol?, screen: Event.Screen, element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.chat, section: Event.Section.chatList, element: element, action: Event.Action.open, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [delete_chat] Delete chat
  static func trackChatListChatDelete(from screen: Event.Screen, element: Event.Element) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.chat, section: Event.Section.chatList, element: element, action: Event.Action.delete)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// Chat tab changed
  static func trackChatTabOpen(_ tab: Event.Element) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.chatList, component: Event.Component.chat, section: Event.Section.chatList, element: tab, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Chat sort changed
  static func trackChatListChatChatListElementTap(_ element: Event.Element) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.chatList, component: Event.Component.chat, section: Event.Section.chatList, element: element, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// Greeting message onboarding viewed
  static func trackScreenGreetingsMessageChatOnboardingView(_ screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.greetingsMessage, section: Event.Section.chat, element: Event.Element.onboarding, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Onboarding "Add greeting" button tapped
  static func trackScreenGreetingsMessageChatOnboardingTap(_ screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.greetingsMessage, section: Event.Section.chat, element: Event.Element.onboarding, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// "Greeting message" button tapped on Manage profile screen
  static func trackManageProfileGreetingsMessageMenuButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.manageProfile, component: Event.Component.greetingsMessage, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// "Greeting message" button tapped in Action sheet menu
  static func trackSaleChatGreetingsMessageChatButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.saleChat, component: Event.Component.greetingsMessage, section: Event.Section.chat, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Turn on/off greeting message on Greeting message screen
  static func trackGreetingsMessageGreetingsMessageSwitchButtonTap(_ isOn: Bool) {
    let parameters: [EventDetailsParameter] = [
      EventDetailsParameter(key: Constants.EventDetails.status, value: isOn ? "on" : "off")
    ]
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.greetingsMessage, component: Event.Component.greetingsMessage, section: Event.Section.switch, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Save button tapped on Greeting message screen
  static func trackGreetingsMessageGreetingsMessageSaveButtonTap(_ text: String) {
    let parameters: [EventDetailsParameter] = [
      EventDetailsParameter(key: Lalafo.Constants.EventDetails.message, value: text)
    ]
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.greetingsMessage, component: Event.Component.greetingsMessage, section: Event.Section.save, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  //TODO: - No event id
  static func trackChatsNotificationOpen() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.chatList, component: Event.Component.chat, section: Event.Section.chatList, element: Event.Element.notification, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [send_message][resend_message][send_image][call] Contact events from Detailed chat
  static func trackScreenСontactSectionButonAction(advertisement: EventAdvertisementProtocol?, screen: Event.Screen, section: Event.Section, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.contact, section: section, element: Event.Element.button, action: action, label: Event.Label.defined(Constants.Analytics.Lalafo.Label.messageEachMessage), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  /// command button tap in chat
  static func trackScreenChatChatButtonActionTap(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.chat, section: Event.Section.chat, element: Event.Element.buttonAction, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenChatChatButtonActionError(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.chat, section: Event.Section.chat, element: Event.Element.buttonAction, action: Event.Action.error, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Cart
  static let cartDefaultParameters: [EventDetailsParameter] = [EventDetailsParameter(key: Lalafo.Constants.EventDetails.responseId, value: "2")]
  /// Add to cart
  static func trackAdCartBuyNowButtonTap(advertisement: Advertisement, parameters: [EventDetailsParameter] = cartDefaultParameters) {
    var params: [EventDetailsParameter] = parameters
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.cart, section: Event.Section.buyNow, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
     trackEvent(event: event)
  }
  ///“View cart”
  static func trackAdCartViewCartButtonTap(advertisement: Advertisement, parameters: [EventDetailsParameter] = cartDefaultParameters) {
    var params: [EventDetailsParameter] = parameters
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.cart, section: Event.Section.viewCart, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
     trackEvent(event: event)
  }
  ///нажатие на иконку  “cart” главной/профиле
  static func trackScreenCartViewCartButtonTap(screen: Event.Screen, parameters: [EventDetailsParameter] = cartDefaultParameters) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.cart, section: Event.Section.viewCart, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
     trackEvent(event: event)
  }
  ///удалить объявления (все, продавца, 1 объявление)
  static func trackCartAdSectionButtonTap(section: Event.Section, advertisement: Advertisement? = nil, parameters: [EventDetailsParameter] = cartDefaultParameters) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.ad, section: section, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
     trackEvent(event: event)
  }
  ///добавить в избранное
  static func trackCartCartAdButtonAddFavorite(advertisement: Advertisement? = nil, parameters: [EventDetailsParameter] = cartDefaultParameters) {
    var params: [EventDetailsParameter] = parameters
    if let advertisement = advertisement {
      params.append(contentsOf: advertisement.getEventDetails())
    }
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.cart, section: Event.Section.ad, element: Event.Element.button, action: Event.Action.addFavorite, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(with: eventDetails)
     trackEvent(event: event)
  }
  ///нажатие на кнопку “Make an order” на корзине
  static func trackCartCartSelectInfoButtonTap(_ parameters: [EventDetailsParameter] = cartDefaultParameters) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.cart, section: Event.Section.selectInfo, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
     trackEvent(event: event)
  }
  // Cart view
  static func trackCartCartViewCartWindowView(_ parameters: [EventDetailsParameter] = cartDefaultParameters) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.cart, section: Event.Section.viewCart, element: Event.Element.window, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  /// открыт экран
  static func trackCartRefugeeConfirmationButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.refugeeConfirmation, section: Event.Section.selectInfo, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  /// Success user identification on diia
  static func trackCartRefugeeConfirmationStatusPopupView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.refugeeConfirmation, section: Event.Section.status, element: Event.Element.popUp, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  ///нажатие на кнопку “Make an order” на форме отправки заявки
  static func trackCartContactBuyNowButtonSendOffer(_ parameters: [EventDetailsParameter] = cartDefaultParameters) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.contact, section: Event.Section.buyNow, element: Event.Element.button, action: Event.Action.sendOffer, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPaymentFondyPopup(element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment, component: Event.Component.fondy, section: Event.Section.popUp, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackUtpScreenUtpModalWindowWindowView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.utpScreen, component: Event.Component.utp, section: Event.Section.modalWindow, element: Event.Element.window, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackUtpScreenCartFeedSectionButtonTap(section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.utpScreen, component: Event.Component.cartFeed, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCartCartCartButtonButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.cart, section: Event.Section.cartButton, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Feeds
  
  /// empty result
  static func trackScreenSearchErrorEmptyResultView(screen: Event.Screen, parameters: [EventDetailsParameter]? = nil) {
    let parameters: [EventDetailsParameter] = parameters ?? []
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.error, element: Event.Element.emptyResults, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackHomeEmptyResultCategoryTabAllView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.emptyResult, section: Event.Section.categoryTab, element: Event.Element.all, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenFeedBannerSectionButtonAction(screen: Event.Screen, appActionType: String?, action: Event.Action, parameters: [EventDetailsParameter]? = nil) {
    let section: Event.Section = appActionType == nil ? .emptyButton: .alternative
    let parameters: [EventDetailsParameter] = parameters ?? []
    var eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.feedBanner, section: section, element: Event.Element.button, action: action, details: Event.Details.defined(parameters))
    eventDetails.alternativeSection = appActionType
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenGoogleBannerBannerFeedBannerAction(screen: Event.Screen, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.googleBanner, section: Event.Section.banner, element: Event.Element.feedBanner, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [send_message] Send message or template message from ad page, home or any listing, buyers and sellers chat
  static func trackChatSendMessage(from screen: Event.Screen, section: Event.Section, label: Event.Label, action: Event.Action, advertisement: Advertisement, parameters: [EventDetailsParameter]?) {
    var params: [EventDetailsParameter] = parameters ?? []
    if label.name == Constants.Analytics.Lalafo.Label.messageFirstMessage {
      if !advertisement.isOfCurrentUser {
        params.append(contentsOf: advertisement.detailsNew())
      }
    }
    params.append(contentsOf: advertisement.getEventDetails())
    params.append(contentsOf: advertisement.getTrackingInfoEventDetails())

    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.contact, section: section, element: Event.Element.button, action: action, label: label, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// [edit_profile]
  static func trackEditProfileFieldEdit(label: Event.Label, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.editProfile, section: Event.Section.fields, element: Event.Element.field, action: Event.Action.edit, label: label, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [edit_profile] Tap on cell 
  static func trackEditProfileEditProfileSectionButtonTap(section: Event.Section, parameters: [EventDetailsParameter] = []) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editProfile, component: Event.Component.editProfile, section: section, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEditProfileProAccountUpgradeProfileButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.editProfile, component: Event.Component.proAccount, section: .upgradeProfile, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Favorites
  /// [addremove_favorites] Add to favorites or remove from favorites from listing and ad screen
  static func trackFavoritesButtonTap(from screen: Event.Screen, section: Event.Section, label: Event.Label, action: Event.Action, advertisement: Advertisement, parameters: [EventDetailsParameter]?) {
    var params: [EventDetailsParameter] = parameters ?? []
    if action == Event.Action.addFavorite {
      if advertisement.isOfCurrentUser == false {
        params.append(contentsOf: advertisement.detailsNew())
      }
    }
    params.append(contentsOf: advertisement.getEventDetails())
    params.append(contentsOf: advertisement.getTrackingInfoEventDetails())

    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.favorites, section: section, element: Event.Element.button, action: action, label: label, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Subscribtion
  /// [subscription_save]
  static func trackSubscribtion(from action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.listing, component: .subscription, section: .feed, element: .button, action: action, label: .undefined, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // TODO: - No event_id
  static func trackSubscribtionOpen(with parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .favorites, component: .subscription, section: .subscriptionList, element: .subscription, action: .open, label: .undefined, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [subscription_delete]
  static func trackSubscribtionDelete() {
    let eventDetails: EventDetails = EventDetails(screen: .favorites, component: .subscription, section: .subscriptionList, element: .button, action: .delete)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [subscription_all_delete]
  static func trackSubscribtionDeleteAll() {
    let eventDetails: EventDetails = EventDetails(screen: .favorites, component: .subscription, section: .subscriptionList, element: .button, action: .deleteAll)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// TODO: - Event not found
  static func trackFavoritesTab(from element: Event.Element) {
    let eventDetails: EventDetails = EventDetails(screen: .favorites, component: .favorites, section: .favorites, element: element, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Tab Bar
  /// [select_tapbar]
  static func trackTabPress(from screen: Event.Screen, element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: .tabBar, section: .tabBar, element: element, action: .tap, label: .undefined, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Invite friends
  /// Invite friends
  // TODO: - Event not found
  static func trackInviteFriendsIconTap(in section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.inviteFriends, component: Event.Component.inviteFriends, section: section, element: Event.Element.icon, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Listing
  /// [view_open_ad_listing]
  static func trackAdvertisement(from screen: Event.Screen, component: Event.Component = .listing, section: Event.Section, element: Event.Element = .ad, action: Event.Action, advertisement: Advertisement, parameters: [EventDetailsParameter]?) {
    var params: [EventDetailsParameter] = parameters ?? []
    if advertisement.isOfCurrentUser == false {
      params.append(contentsOf: advertisement.detailsNew())
    }
    params.append(contentsOf: advertisement.getEventDetails())

    let eventDetails: EventDetails = EventDetails(screen: screen, component: component, section: section, element: element, action: action, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Helper func for tracking ads from custom feeds
  static func trackFeedAdvertisement(from screen: Event.Screen, component: Event.Component, section: Event.Section, element: Event.Element, action: Event.Action, advertisement: Advertisement, parameters: [EventDetailsParameter] = []) {
    var parameters: [EventDetailsParameter] = parameters
    if let params = advertisement.meta?.getFeedEventDetailsParameters() {
      parameters.append(contentsOf: params)
    }
    for item in advertisement.trackingInfo {
      parameters.append(item.getEventDetailsParameter())
    }
    if let responseTime = advertisement.owner?.responseTime {
      parameters.append(EventDetailsParameter(key: Constants.EventDetails.responseTime, value: "\(responseTime)"))
    }
    if let responseRate = advertisement.owner?.responseRate {
      parameters.append(EventDetailsParameter(key: Constants.EventDetails.responseRate, value: "\(responseRate)"))
    }
    EventsTracker.trackAdvertisement(from: screen, component: component, section: section, element: element, action: action, advertisement: advertisement, parameters: parameters)
  }

  // MARK: - Track Map Screen
  static func trackSearchMapScreen(section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: .listing, component: .searchMap, section: section, element: .map, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Track Pin On Search Map Screen
  static func trackPinsOnMap(action: Event.Action, pin: MapPin, parameters: [EventDetailsParameter]?) {
    var parameters = parameters ?? []
    parameters.append(contentsOf: pin.getEventParameters())

    let eventDetails: EventDetails = EventDetails(screen: .listing, component: .searchMap, section: .feed, element: .pin, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Categories  
  static func trackFiltersSearchList(element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.filters, component: Event.Component.search, section: Event.Section.list, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackFiltersSearchFiltersElement(action: Event.Action, parameters: [EventDetailsParameter]) {
    trackSearchFilters(from: .filters, element: .element, action: action, parameters: parameters)
  }
  
  static func trackFiltersSearchFiltersResetAllTap(parameters: [EventDetailsParameter]) {
    trackSearchFilters(from: .filters, element: .resetAll, action: .tap, parameters: parameters)
  }
  
  static func trackSearchFilters(from screen: Event.Screen, element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.filters, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [open_pro_account_list] categories screen
  static func trackCategoryMenuTap(from screen: Event.Screen, element: Event.Element, section: Event.Section, parameters: [EventDetailsParameter]?) {
    let parameters = parameters ?? []    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: section, element: element, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCategoryMenuSelect(from screen: Event.Screen, element: Event.Element, section: Event.Section, parameters: [EventDetailsParameter]?) {
    let parameters = parameters ?? []
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: section, element: element, action: Event.Action.select, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [open_pro_account_list] choose pro account in tab / menu
  static func trackSearchScreenProAccountSectionLinkTap(from screen: Event.Screen, section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccount, section: section, element: Event.Element.link, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // TODO: - Event not found
  static func trackSearchCategoryBackTap(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.categoryMenu, element: Event.Element.back, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Post
  static func trackPostingButtonTap(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.posting, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [add_photo_camera] Add photo from camera
  static func trackPostCameraPhotoAdd(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.camera, element: Event.Element.photo, action: Event.Action.add)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [add_photo_gallery] Add photo from gallery
  static func trackPostGalleryPhotoAdd(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.gallery, element: Event.Element.photo, action: Event.Action.add)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [add_description] Add description
  static func trackPostDescriptionFieldInput(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.description, element: Event.Element.field, action: Event.Action.input)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [add_item] Add ad
  static func trackPostAddItemButtonTap(from screen: Event.Screen, label: String) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.addItem, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // TODO: - 2 events in one method
  /// [recommended_category] [basic_category] Select recommended or basic category
  static func trackPostCategorySelect(advertisement: EventAdvertisementProtocol, screen: Event.Screen, section: Event.Section,  label: String) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: section, element: Event.Element.category, action: Event.Action.select, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// [posting_price] Enter price
  static func trackPostPriceFieldApply(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.price, element: Event.Element.field, action: Event.Action.apply)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// Select param
  /// [add_description]
  static func trackPostParameterFieldInput(from screen: Event.Screen, label: String) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.param, element: Event.Element.field, action: Event.Action.input, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [posting_params] ?
  static func trackPostParameterFieldSelect(from screen: Event.Screen, label: String) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.param, element: Event.Element.field, action: Event.Action.select, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [posting_location] Choose location during posting
  static func trackPostLocationMapSelect(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.location, element: Event.Element.map, action: Event.Action.select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [phone_code] Choosing phone code
  static func trackPostPhoneCodeSelect(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.phone, element: Event.Element.code, action: Event.Action.select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [phone_number] Editing phone number
  static func trackPostPhoneNumberApply(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.phone, element: Event.Element.number, action: Event.Action.apply)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [skip_step] Skip step during posting
  static func trackPostSkipButtontap(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.skip, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [publish_ad] Publish ad
  static func trackPostingComponentPostElementTap(component: Event.Component, element: Event.Element, label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.posting, component: component, section: Event.Section.publish, element: element, action: Event.Action.tap, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Thank you page list more tapped
  static func trackPostingSuccessPostListMoreButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.postingSuccess, component: Event.Component.post, section: Event.Section.listMore, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  /// Thank you page view
  static func trackPostingSuccessPostListMoreButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.postingSuccess, component: Event.Component.post, section: Event.Section.listMore, element: Event.Element.button, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Report
  /// [report_ad] Report ad
  static func trackScreenReportListReasonSelect(advertisement: Advertisement, screen: Event.Screen, label: String) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.report, section: Event.Section.list, element: Event.Element.reason, action: Event.Action.select, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [report_user] Report user
  static func trackScreenReportListReasonSelect(screen: Event.Screen, label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.report, section: Event.Section.list, element: Event.Element.reason, action: Event.Action.select, label: Event.Label.defined(label), details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Filters
  /// [open_filters]
  static func trackSearchFiltersOpen(from screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.filters, element: Event.Element.icon, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // FIXME: - Need merge methods [filters_page]
  /// [filters_page]
  static func trackFiltersCloseTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.filters, component: Event.Component.search, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [filters_page]
  static func trackFiltersApplyTap(screen: Event.Screen, section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: section, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.undefined, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Search
  /// [search_subscription] Select subscription
  static func trackScreenSearchListSubscriptionOpen(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.list, element: Event.Element.subscription, action: Event.Action.open, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
    
  /// [search_suggestions] Select search suggestion
  static func trackScreenSearchListElementApply(screen: Event.Screen, element: Event.Element, label: String, parameters: [EventDetailsParameter]) {    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.list, element: element, action: Event.Action.apply, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenSearchListElementAction(screen: Event.Screen, element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.search, section: Event.Section.list, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [top_filters] View or select
  static func trackListingSearchTopFiltersButtonAction(action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.listing, component: Event.Component.search, section: Event.Section.topFilters, element: Event.Element.button, action: action, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackListingSearchLinkQueryApply(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.listing, component: Event.Component.search, section: Event.Section.link, element: Event.Element.query, action: Event.Action.apply, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Country
  /// [select_country] Select country in settings or auto-detect country during app loading
  static func trackCountrySettings(label: String, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.country, component: Event.Component.settings, section: Event.Section.country, element: Event.Element.field, action: action, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Language
  /// [select_language] Select language in settings
  static func trackLanguageSettingsLanguageFieldSelect(label: String, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.language, component: Event.Component.settings, section: Event.Section.language, element: Event.Element.field, action: action, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - VAS
  /// [buy_from_ad_details] Tap on payment button
  static func trackMyAdvertisementVasSectionButtonTap(advertisement: Advertisement, section: Event.Section, label: String?, parameters: [EventDetailsParameter]) {
    let eventLabel = label != nil ? Event.Label.defined(label!) : Event.Label.undefined
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.vas, section: section, element: Event.Element.button, action: Event.Action.tap, label: eventLabel, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// [select_buy_from_ad_details] Change slider value in magic button slider section
  static func trackMyAdvertisementVasSectionSliderSelect(advertisement: Advertisement, section: Event.Section, label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.vas, section: section, element: Event.Element.slider, action: Event.Action.select, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Tap on Activate Button (feed)
  static func trackMyProfileAdActivateButtonButtonTap(advertisement: Advertisement) {
    var params: [EventDetailsParameter] = []
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.ad, section: Event.Section.activate, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Tap on Promotion Button (feed)
  static func trackMyProfileAdAdvertisementButtonButtonTap(advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.ad, section: Event.Section.advertiseButton, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Tap on Promotion Button (ad details)
  static func trackMyAdPPVSectionButtonTap(_ section: Event.Section, advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppv, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyAdPPVBPSectionButtonTap(_ section: Event.Section, advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppvBP, section: section, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Tap on Promotion Button (ad details)
  static func trackMyAdVASSectionButtonTap(_ section: Event.Section, advertisement: Advertisement) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.vas, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyAdVASBPSectionButtonTap(_ section: Event.Section, advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.vasBp, section: section, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// [1_sell_faster] Tap on Sell faster button
  static func trackScreenComponentSectionElementTap(_ screen: Event.Screen, component: Event.Component, section: Event.Section, element: Event.Element, advertisement: Advertisement, parameters: [EventDetailsParameter] = []) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: component, section: section, element: element, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// [2_select_ads] Select ad in complex purchase
  static func trackVasVasVasSellFasterButtonSelectAd(label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.vas, component: Event.Component.vas, section: Event.Section.vasSellFaster, element: Event.Element.button, action: Event.Action.selectAd, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [3_select_features] Select feature in old vas screen (OV) or complex purchase (CP)
  static func trackVasVasSectionButtonSelect(section: Event.Section, label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.vas, component: Event.Component.vas, section: section, element: Event.Element.button, action: Event.Action.select, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Free vas
  /// [free_pushup] Tap on free push up
  static func trackMyAdvertisementFreeVasPushUpButtonTap(advertisement: Advertisement?) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.freeVas, section: Event.Section.pushUp, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Share
  /// [share] Tap on share button
  static func trackShareTap(from screen: Event.Screen, advertisement: Advertisement?, paramaters: [EventDetailsParameter]? = nil) {
    var params: [EventDetailsParameter] = paramaters ?? []
    if let advertisement = advertisement {
      params.append(contentsOf: advertisement.getEventDetails())
    }
    
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.share, section: Event.Section.systemButton, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Map
  /// [map] Set something on map
  static func trackMapShortcutTap(from screen: Event.Screen, section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.map, section: section, element: Event.Element.map, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Contact
  /// [call]
  static func trackAdvertisementCall(screen: Event.Screen, section: Event.Section, advertisement: Advertisement, parameters: [EventDetailsParameter]?) {

    var params: [EventDetailsParameter] = parameters ?? []
    if !advertisement.isOfCurrentUser {
      params.append(contentsOf: advertisement.detailsNew())
    }
    params.append(contentsOf: advertisement.getEventDetails())
    params.append(contentsOf: advertisement.getTrackingInfoEventDetails())
    
    if let responseTime = advertisement.owner?.responseTime {
      params.append(EventDetailsParameter(key: Lalafo.Constants.EventDetails.responseTime, value: "\(responseTime)"))
    }
    if let responseRate = advertisement.owner?.responseRate {
      params.append(EventDetailsParameter(key: Lalafo.Constants.EventDetails.responseRate, value: "\(responseRate)"))
    }

    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.contact, section: section, element: Event.Element.button, action: Event.Action.call, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [WhatsApp]
  static func trackScreenContactSocialButtonСall(screen: Event.Screen, advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.contact, section: Event.Section.social, element: Event.Element.button, action: Event.Action.call, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [write_tap]
  static func trackAdvertisementButtonWriteTap(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    var params: [EventDetailsParameter] = parameters
    params.append(contentsOf: advertisement.getEventDetails())
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.contact, section: Event.Section.write, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAdProAccountContactButtonTap(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
      screen: Event.Screen.ad,
      section: Event.Section.proAccount,
      component: Event.Component.contact,
      element: Event.Element.button,
      action: Event.Action.tap,
      details: Event.Details.defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackProContactSocialProAccountContactsButtonView(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
      screen: Event.Screen.proContact,
      section: Event.Section.social,
      component: Event.Component.proAccountContacts,
      element: Event.Element.button,
      action: Event.Action.view,
      details: Event.Details.defined(parameters)
    )
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Pro Accounts
  /// [pro_contacts] Open contacts in pro account
  static func trackContactProAccountButtonTap(from screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.contact, section: Event.Section.proAccount, element: Event.Element.button, action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  ///[pro_account_banner_tap] tap on banner buy pro
  static func trackProAccountProAccountMenuButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccount, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [pro_account_send_number] send phone number
  static func trackProAccountProAccountPopUpButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.proAccount, component: Event.Component.proAccount, section: Event.Section.popUp, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Pro Account contacts
  static func trackLalafoBusinessBPHeaderBannerTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.lalafoBusiness, component: Event.Component.bp, section: Event.Section.header, element: Event.Element.banner, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // https://docs.google.com/spreadsheets/d/1KQ8NZpk22NBDKMZq5AkqOJIfPXgMbCnZ1KWZ7R-8dyo/edit#gid=0
  /// [pro_sociaI_name_button] View or open social networks
  static func trackScreenProAccountContactsSocialButtonAction(screen: Event.Screen, action: Event.Action, label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccountContacts, section: Event.Section.social, element: Event.Element.button, action: action, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [pro_link__button] Link to the site on 'contacts' pro-accounts
  static func trackScreenProAccountContactsWebsiteButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccountContacts, section: Event.Section.website, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [shedule__button] View shedule on 'contacts' pro-accounts
  static func trackScreenProAccountContactsListButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccountContacts, section: Event.Section.list, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [ad|pro_map] Open and view map
  static func trackScreenProAccountContactsMapMapAction(screen: Event.Screen, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccountContacts, section: Event.Section.map, element: Event.Element.map, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Notifications
  /// [push_notification_permission]
  static func trackNotificationsPushPermissionPermissionAction(action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.notifications, component: Event.Component.push, section: Event.Section.permission, element: Event.Element.permission, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackNotificationsPushPushOpen(alternativeSection: String, parameters: [EventDetailsParameter]) {
    var eventDetails: EventDetails = EventDetails(screen: Event.Screen.notifications, component: Event.Component.push, section: .alternative, element: Event.Element.push, action: Event.Action.open, details: Event.Details.defined(parameters))
    eventDetails.alternativeSection = alternativeSection
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Make Offer
  /// [make_an_offer_button]
  static func trackAdvertisementContactMakeAnOfferButtonTap(advertisement: Advertisement?) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.contact, section: Event.Section.makeAnOffer, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Wallet
  /// [wallet_open] open wallet
  static func trackScreenWalletMenuButtonTap(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.wallet, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenWalletAfterPPVPriceButtonView(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.walletAfterPPV, section: Event.Section.price, element: Event.Element.button, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenWalletRecommendedButtonView(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.walletRecommended, section: Event.Section.price, element: Event.Element.button, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletAfterPPVPriceButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet, component: Event.Component.walletAfterPPV, section: Event.Section.price, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletPriceButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet, component: Event.Component.wallet, section: Event.Section.price, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletBpInfoDiscountButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet, component: Event.Component.bpInfo, section: Event.Section.discount, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletComponentPriceFieldError(_ component: Event.Component,
                                                  parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(
      screen: Event.Screen.wallet,
      component: component,
      section: Event.Section.price,
      element: Event.Element.field,
      action: Event.Action.error,
      details: Event.Details.defined(parameters))
    
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [wallet_replenish] replenish button tap
  static func trackScreenComponentPriceButtonTap(_ screen: Event.Screen,
                                                 component: Event.Component,
                                                 parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: component, section: Event.Section.price, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Wallet freedom withdraw
  static func trackWalletWithdrawFormSectionButtonTap(_ section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet, component: Event.Component.withdrawForm, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWithdrawFormWalletWithdrawFormScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.wallet, section: Event.Section.withdrawForm, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWithdrawFormWalletWithdrawFormButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.wallet, section: Event.Section.withdrawForm, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWithdrawFormConfirmationScreenConfirmationScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.confirmationScreen, section: Event.Section.confirmationScreen, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWithdrawFormConfirmationScreenCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.confirmationScreen, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  static func trackWithdrawFormConfirmationScreenConfirmButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.confirmationScreen, section: Event.Section.confirm, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWithdrawFormThankYouPageThankYouPageScreenView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.thankYouPage, section: Event.Section.thankYouPage, element: Event.Element.screen, action: Event.Action.view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWithdrawFormThankYouPageCloseButtonActionTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.withdrawForm, component: Event.Component.thankYouPage, section: Event.Section.close, element: Event.Element.buttonAction, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// [error_replemishment_button] an error during replenishment
  static func trackPaymentWalletPopupButtonTap(label: String, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment, component: Event.Component.wallet, section: Event.Section.popUp, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.defined(label), details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [all_seller_items_button] View or tap on 'all seller items' button
  static func trackViewOrTapOnAllSellerItemsButton(action: Event.Action, parameters: [EventDetailsParameter] = []) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.allSellerItems, section: Event.Section.user, element: Event.Element.button, action: action, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// [updates_banner]
  static func trackUpdateTap(element: Event.Element, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.banner, section: Event.Section.updatesBanner, element: element, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// show pop up for autoreplenishment # payment ppv popup auto_replenishment  view
  static func trackPaymentPPVPopupAutoReplenishView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment,
                                    component: Event.Component.ppv,
                                    section: Event.Section.popUp,
                                    element: Event.Element.autoReplenishment,
                                    action: Event.Action.view,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// settings button tap
  static func trackPaymentPPVPopupButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment,
                                    component: Event.Component.ppv,
                                    section: Event.Section.popUp,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// skip button tap
  static func trackPaymentPPVPopupButtonSkip(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment,
                                    component: Event.Component.ppv,
                                    section: Event.Section.popUp,
                                    element: Event.Element.button,
                                    action: Event.Action.skip,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// close button tap
  static func trackPaymentPPVPopupButtonClose(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment,
                                    component: Event.Component.ppv,
                                    section: Event.Section.popUp,
                                    element: Event.Element.button,
                                    action: Event.Action.close,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletSettingButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.wallet,
                                    section: Event.Section.settings,
                                    element: Event.Element.button,
                                    action: Event.Action.view,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletSettingButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.wallet,
                                    section: Event.Section.settings,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletHistoryButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.settings,
                                    section: Event.Section.history,
                                    element: Event.Element.button,
                                    action: Event.Action.view,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletHistoryButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.settings,
                                    section: Event.Section.history,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletAutoReplenishmentButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.settings,
                                    section: Event.Section.autoReplenishment,
                                    element: Event.Element.button,
                                    action: Event.Action.view,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletAutoReplenishmentButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.settings,
                                    section: Event.Section.autoReplenishment,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAutoReplenishmentWalletActivateButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.autoReplenishment,
                                    component: Event.Component.wallet,
                                    section: Event.Section.activate,
                                    element: Event.Element.button,
                                    action: Event.Action.view,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAutoReplenishmentWalletActivateButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.autoReplenishment,
                                    component: Event.Component.wallet,
                                    section: Event.Section.activate,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAutoReplenishmentWalletSaveButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.autoReplenishment,
                                    component: Event.Component.wallet,
                                    section: Event.Section.save,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletActivateButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.wallet,
                                    section: Event.Section.activate,
                                    element: Event.Element.button,
                                    action: Event.Action.view,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletWalletActivateButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.wallet,
                                    section: Event.Section.activate,
                                    element: Event.Element.button,
                                    action: Event.Action.tap,
                                    details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletPromocodeWalletButtonTap(_ screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen,
                                    component: Event.Component.promocode,
                                    section: Event.Section.wallet,
                                    element: Event.Element.button,
                                    action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackPaymentPPVPopupOnboardingTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.payment,
                                    component: Event.Component.ppv,
                                    section: Event.Section.popUp,
                                    element: Event.Element.onboarding,
                                    action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackWalletWalletActivateOnboardingTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.wallet,
                                    section: Event.Section.activate,
                                    element: Event.Element.onboarding,
                                    action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackWalletAutoReplenishmentSettingsOnboardingTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.autoReplenishment,
                                    section: Event.Section.settings,
                                    element: Event.Element.onboarding,
                                    action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackWalletAutoReplenishmentSettingsOnboardingView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.wallet,
                                    component: Event.Component.autoReplenishment,
                                    section: Event.Section.settings,
                                    element: Event.Element.onboarding,
                                    action: Event.Action.view)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  // MARK: - Promocodes
  // TODO: - Not Found in Confluence Events
  static func trackMyProfilePromocodeMenuButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.promocode, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  // TODO: - Not Found in Confluence Events
  static func trackPromocodePromocodeAddCodeButtonTap(label: String) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.promocode, component: Event.Component.promocode, section: Event.Section.addCode, element: Event.Element.button, action: Event.Action.tap, label: Event.Label.defined(label))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Job (https://yallaclassifieds.atlassian.net/browse/DV-4469)

  /// Apply_job_listing
  static func trackScreenApplyJobAdButtonAction(advertisement: EventAdvertisementProtocol?, screen: Event.Screen, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.applyJob, section: Event.Section.ad, element: Event.Element.button, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Apply_job_from_ad
  static func trackAdApplyJobUserAdsButtonAction(advertisement: EventAdvertisementProtocol?, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.applyJob, section: Event.Section.userAds, element: Event.Element.button, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Apply_job_from_ad
  static func trackAdApplyJobChatButtonAction(advertisement: EventAdvertisementProtocol?, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.applyJob, section: Event.Section.chat, element: Event.Element.button, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Create_CV
  static func trackCVBuilderApplyJobWelcomeButtonTap(advertisement: EventAdvertisementProtocol?, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cvBuilder, component: Event.Component.applyJob, section: Event.Section.welcome, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Apply_job_from_CVBuilder
  static func trackCVBuilderContactCVSendButtonTap(advertisement: EventAdvertisementProtocol?, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cvBuilder, component: Event.Component.contact, section: Event.Section.cvSend, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Apply_CV
  static func trackCVListContactCVSendButtonTap(advertisement: EventAdvertisementProtocol?, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cvList, component: Event.Component.contact, section: Event.Section.cvSend, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Apply_CV
  static func trackCVListApplyJobCVCreateButtonTap(advertisement: EventAdvertisementProtocol?, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cvList, component: Event.Component.applyJob, section: Event.Section.cvCreate, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - PPV (https://yallaclassifieds.atlassian.net/browse/DV-4463)
  
  static func trackPPVPayBPButtonView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .pay, section: .bp, element: Event.Element.button, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVPopupPPVInfoButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppvInfo, section: Event.Section.popUp, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVPopupPPVInfoPopUpPageView(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppvInfo, section: Event.Section.popUp, element: Event.Element.popupPage, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_start (tap on start advertise button)
  static func trackPPVPPVAfterPostingButtonTap(advertisement: Advertisement, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: Event.Section.ppvAfterPosting, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_free (tap on advertise for free button)
  static func trackPPVPPVScreenSectionButtonTap(advertisement: Advertisement, screen: Event.Screen, section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: section, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_start_banner (tap on start advertise from the banner)
  static func trackPPVBannerButtonTap(advertisement: Advertisement, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: Event.Section.banner, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Advertise upgrade to BP tap  (tap on updade to BP from the banner)
  static func trackPPVBPBannerButtonTap(advertisement: Advertisement, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: Event.Section.bpBanner, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Present PPV screen
  static func trackScreenSectionPPVPopupView(screen: Event.Screen,
                                             section: Event.Section,
                                             parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: section, element: Event.Element.popup, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Tap on details about paid posting (top banner on PPV screen)
  static func trackPPVPaymentURLTap(advertisement: Advertisement, screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: Event.Section.paymentURL, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Tap buy Business account on PPV
  static func trackPPVBPPayButtonTap(advertisement: Advertisement, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.bp, section: Event.Section.pay, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// call back to upgrade to BP
  static func trackPPVBPCallBackButtonTap(advertisement: Advertisement?, screen: Event.Screen, parameters: [EventDetailsParameter]) -> EventModel {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.bp, section: Event.Section.callBack, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
    return event
  }
  
  /// Track gradation tap in cell
  static func trackScreenBPLimitScreenButtonTap(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.bp, section: Event.Section.limitScreen, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Track select button tap on categories screen
  static func trackScreenBPSelectLimitButtonTap(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.bp, section: Event.Section.selectLimit, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Track balance slider value change
  static func trackScreenBPSelectBalanceButtonTap(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.bp, section: Event.Section.selectBalance, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_free_banner (tap on free advertise button)
  static func trackPPVFreeBannerButtonTap(advertisement: Advertisement, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: Event.Section.freeBanner, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_start (tap on start advertise button)
  static func trackMyAdPPVAdvertiseButtonTap(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppv, section: Event.Section.advertiseButton, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_start (tap on start advertise button)
  static func trackPPVAdvertiseButtonTap(advertisement: Advertisement, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.ppv, section: Event.Section.advertiseButton, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  static func trackMyAdEditCampaignPPVButtonTap(advertisement: Advertisement) {
    var params: [EventDetailsParameter] = []
    if let campaignId = advertisement.campaigns.first?.id {
      params.append(EventDetailsParameter(key: Constants.EventDetails.campaignId,
                                          value: "\(campaignId)"))
    }
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppv, section: Event.Section.editCampaign, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  /// Advertise_stop (tap on stop button in modal screen)
  static func trackMyAdPPVAdvertiseStopButtonTap(advertisement: Advertisement) {
    var params: [EventDetailsParameter] = []
    if let campaignId = advertisement.campaigns.first?.id {
      params.append(EventDetailsParameter(key: Constants.EventDetails.campaignId,
                                          value: "\(campaignId)"))
    }
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppv, section: Event.Section.advertiseStop, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  /// Advertise_stop_banner_yes (tap on yes button on banner)
  static func trackMyAdPPVAdvertiseStopButtonTapYesOrNo(advertisement: Advertisement, parameters: [EventDetailsParameter]) {
    var params: [EventDetailsParameter] = parameters
    if let campaignId = advertisement.campaigns.first?.id {
      params.append(EventDetailsParameter(key: Constants.EventDetails.campaignId,
                                          value: "\(campaignId)"))
    }
    
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myAd, component: Event.Component.ppv, section: Event.Section.advertiseStop, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - My Account (https://yallaclassifieds.atlassian.net/browse/DV-5207)
  /// business_select_package (tap on package)
  static func trackImproveProfileBPUpgradeButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.improveProfile, component: Event.Component.bp, section: Event.Section.upgrade, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// manage_profile
  static func trackMyProfileProAccountMenuButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.proAccount, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// improve_profile
  static func trackScreenProAccountMenuButtonTap(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccount, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// create_business_profile
  static func trackScreenProAccountFieldsButtonTap(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.proAccount, section: Event.Section.fields, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// not_interesting
  static func trackOnboardingProAccountSkipButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.onboarding, component: Event.Component.proAccount, section: Event.Section.skip, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// Next
  static func trackOnboardingProAccountOnboardingButtonAction(action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.onboarding, component: Event.Component.proAccount, section: Event.Section.onboardingButton, element: Event.Element.button, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  /// activate_for_free
  static func trackOnboardingProAccountActivateButtonAction(action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.onboarding, component: Event.Component.proAccount, section: Event.Section.activate, element: Event.Element.button, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  static func trackMyProfileMenuEfficiencyButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.menu, section: Event.Section.efficiency, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyProfileMenuFreedomLimitButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.menu, section: Event.Section.freedomLimit, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEfficiencyRecommendedShowDescriptionTextButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.efficiency, component: Event.Component.recommended, section: Event.Section.showDescriptionText, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEfficiencyRecommendedShowRecomTextButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.efficiency, component: Event.Component.recommended, section: Event.Section.showRecomText, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEfficiencyRecommendedRecommendedButtonActionTap(_ params: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.efficiency, component: Event.Component.recommended, section: Event.Section.recommended, element: Event.Element.buttonAction, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEfficiencyEfficiencyAboutMetricsButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.efficiency, component: Event.Component.efficiency, section: Event.Section.aboutMetrics, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEfficiencyRecommendedFilterButtonTap(_ params: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.efficiency, component: Event.Component.recommended, section: Event.Section.filters, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackEfficiencyRecommendedRecommendationCardView(_ params: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.efficiency, component: Event.Component.recommended, section: Event.Section.recommendation, element: Event.Element.card, action: Event.Action.view, details: Event.Details.defined(params))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyProfilePPVFreeLimitButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.ppv, section: Event.Section.freeLimit, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackMyProfileEditHeaderButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.edit, section: Event.Section.header, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  static func trackMyProfileProfileHeaderButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.profile, section: Event.Section.header, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  // MARK: - Freedom events (https://yallaclassifieds.atlassian.net/browse/DV-5449)
  /// просмотр, открытие объявлений на личном профиле
  static func trackMyProfileListingSectionAdAction(section: Event.Section, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.listing, section: section, element: Event.Element.ad, action: action)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Флоу постинга, выбор типа, отслеживания ошибок ({is_freedom: true|false; error:  })
  static func trackScreenPostPostingTypeButtonSelect(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.vasPosting, element: Event.Element.button, action: Event.Action.select, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Freedom постинг первый шаг, выбор коробки, переход на след.шаг
  static func trackScreenPostVolumeButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.volume, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Freedom постинг второй шаг, выбор даты вызова курьера
  static func trackScreenPostDateButtonSelect(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.post, section: Event.Section.date, element: Event.Element.button, action: Event.Action.select, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Freedom постинг третий шаг, нажа кнопка изменить заказ
  static func trackPostingPostMyOrderButtonEdit() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.posting, component: Event.Component.post, section: Event.Section.myOrder, element: Event.Element.button, action: Event.Action.edit)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// "Freedom постинг третий шаг, создание заказа (передавать доп. параметры: сума заказа и количество коробок) отслеживать ошибки" {sum: ;currency: ; box: ; error:   }
  static func trackPostingPostPublishButtonTap(label: Event.Label, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.posting, component: Event.Component.post, section: Event.Section.publish, element: Event.Element.button, action: Event.Action.tap, label: label, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Профиль с Freedom аккаунтом, открытие комментариев
  static func trackMyProfileFeedbackMenuButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.feedback, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Профиль с Freedom аккаунтом, открытие информации о курьере
  static func trackMyProfileCourierMenuButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.courier, section: Event.Section.menu, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  /// Показ інформації про пуш що можна замовити безкоштовні речі з Freedom (кнопка показати речі)
  static func trackActivationFormActivationLinkButtonTap() {
    let eventDetails: EventDetails = EventDetails(
      screen: Event.Screen.activationForm,
      component: Event.Component.activation,
      section: Event.Section.link,
      element: Event.Element.button,
      action: Event.Action.tap
    )
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Показ інформації про пуш що можна замовити безкоштовні речі з Freedom (кнопка закрити)
  static func trackActivationFormActivationCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(
      screen: Event.Screen.activationForm,
      component: Event.Component.activation,
      section: Event.Section.close,
      element: Event.Element.button,
      action: Event.Action.tap
    )
    trackEvent(event: EventFactory.event(with: eventDetails))
  }


//  /// Профиль с Freedom аккаунтом, просмотр обьяв во вкладках donation и recycle
//  static func trackMyProfileListingSectionAdAction(section: Event.Section, action: Event.Action) {
//    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.listing, section: section, element: Event.Element.ad, action: action)
//    trackEvent(event: EventFactory.event(with: eventDetails))
//  }

  /// Информация о курьере, нажата кнопка позвоинть
  static func trackMyOrderCourierCourierButtonCall() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myOrder, component: Event.Component.courier, section: Event.Section.courier, element: Event.Element.button, action: Event.Action.call)
     trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Список отзывов о Freedom товарах, переход на товар
  static func trackFeedbackFeedbackListAdAction(action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.feedback, component: Event.Component.feedback, section: Event.Section.list, element: Event.Element.ad, action: action)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Подтверждение товаров, нажата кнопка подтвердить {Group ID: count ; error:   }
  static func trackScreenConfirmationMyOrderButtonTap(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.confirmation, section: Event.Section.myOrder, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
      trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Подтверждение товаров, открытие деталей товара
  static func trackItemListConfirmationListItemAction(action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.itemList, component: Event.Component.confirmation, section: Event.Section.list, element: Event.Element.item, action: action)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// "Подтверждение товаров, изминение групы для одного товара *добавить номер заказа (но у нас нет такого поля)" {Group ID: count ; error:   }
  static func trackItemListConfirmationStatusListButtonTap(parameters: [EventDetailsParameter] = []) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.itemList, component: Event.Component.confirmation, section: Event.Section.statusList, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
      trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Подтверждение товаров, открыто окно возврата вещи
  static func trackItemListConfirmationPopupButtonView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.itemList, component: Event.Component.confirmation, section: Event.Section.popUp, element: Event.Element.button, action: Event.Action.view)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Подтверждение товаров, пользователь подтверидл возврат вещи  {Group ID: count ; error:   }
  static func trackItemListConfirmationPopupButtonTap(parameters: [EventDetailsParameter] = []) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.itemList, component: Event.Component.confirmation, section: Event.Section.popUp, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Подтверждение товаров, пользователь отменил возврат вещи
  static func trackItemListConfirmationStatusListItemTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.itemList, component: Event.Component.confirmation, section: Event.Section.statusList, element: Event.Element.item, action: Event.Action.tap)
      trackEvent(event: EventFactory.event(with: eventDetails))
  }

  /// Подтверждение товаров, пользователь просмотрел вещи со списка
  static func trackItemListConfirmationListItemView() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.itemList, component: Event.Component.confirmation, section: Event.Section.list, element: Event.Element.item, action: Event.Action.view)
      trackEvent(event: EventFactory.event(with: eventDetails))
  }
  /// При заходе в приложение корзина автоматически откроется
  /// home:autocart:view_cart:button:tap
  static func trackHomeAutocartViewCartButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.autocart, section: Event.Section.viewCart, element: Event.Element.button, action: Event.Action.tap)
      trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  /// пользователь нажал на иконку крестика на блоке купленых товаров в корзине
  /// cart:bought_alert:close:button:tap
  static func trackCartBoughtAlertCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.boughtAlert, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap)
      trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  /// пользователь нажал на иконку крестика на блоке прошествии времени
  /// cart:order3h_alert:close:button:tap
  static func trackCartOrder3hAlertCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.order3hAlert, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap)
      trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  /// На странице товара  “buy it now”
  /// ad:purchase:buy_now:button:tap
  static func trackAdPurchaseBuynowButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.purchase, section: Event.Section.buyNow, element: Event.Element.button, action: Event.Action.tap)
      trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  /// “buy it now” в корзине не было товаров
  /// ad:purchase:select_info:button:tap
  static func trackAdPurchaseSelectInfoButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.purchase, section: Event.Section.selectInfo, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  /// корзине находится 3 и более товара
  /// ad:purchase:view_cart:button:tap
  static func trackAdPurchaseViewCartButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.ad, component: Event.Component.purchase, section: Event.Section.viewCart, element: Event.Element.button, action: Event.Action.tap)
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
  
  // New ad details UI elements
  static func trackAdCityDetailsButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.ad,
          section: Event.Section.city,
          component: Event.Component.details,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
      trackEvent(event: event)
  }

  static func trackAdDescriptionDetailsButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.ad,
          section: Event.Section.description,
          component: Event.Component.details,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
      trackEvent(event: event)
  }

  static func trackAdParamsDetailsButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.ad,
          section: Event.Section.params,
          component: Event.Component.details,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
      trackEvent(event: event)
  }

  static func trackAdAllDetailsDetailsButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.ad,
          section: Event.Section.allDetails,
          component: Event.Component.details,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
      trackEvent(event: event)
  }

  static func trackAdMapDetailsButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.ad,
          section: Event.Section.map,
          component: Event.Component.details,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
      trackEvent(event: event)
  }

  // MARK: - Screen Views
  static func trackApplicationScreenView(screen: Event.Screen) {
    trackScreenView(screen: screen)
  }
  
  // MARK: - Internal HOME banners
  static func trackHomeBannerHomeHeaderBannerButton(action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.banner, section: Event.Section.homeHeaderBanner, element: Event.Element.button, action: action, details: Event.Details.defined(parameters))
    trackEvent(event: EventFactory.event(with: eventDetails))
  }
}

// MARK: - Modal Communication Analytics
extension EventsTracker {
    
  static func trackScreenFormFormFormPull(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.form, section: Event.Section.form, element: Event.Element.form, action: Event.Action.pull, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenFormFormFormView(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.form, section: Event.Section.form, element: Event.Element.form, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackModalFormSectionFormDelete(section: Event.Section, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.modal, component: Event.Component.form, section: section, element: Event.Element.form, action: Event.Action.delete, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackModalFormCloseButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.modal, component: Event.Component.form, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackModalFormButtonElementTap(element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.modal, component: Event.Component.form, section: Event.Section.button, element: element, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackModalFormButtonSendTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.modal, component: Event.Component.form, section: Event.Section.button, element: Event.Element.send, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackModalFormErrorErrorView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.modal, component: Event.Component.form, section: Event.Section.error, element: Event.Element.error, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackModalFormErrorButtonActionView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.modal, component: Event.Component.form, section: Event.Section.error, element: Event.Element.buttonAction, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Reach Profile
//  Натиснення. кнопки deactivate при масовому виборі оголошень на вкладці активних оголошень
  static func trackMyProfileMassDeactivationButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.massDeactivation, section: Event.Section.deactivate, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Натиснення. кнопки delete при масовому виборі оголошень на вкладці відхилених оголошень
  static func trackMyProfileMassDeletionButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.massDeletion, section: Event.Section.delete, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Перегляд кнопки Promote після вибору значення на ползунку
  static func trackMyProfileReachCategoryPromoteButtonView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promote, element: Event.Element.button, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на кнопку Promote після вибору значення на ползунку
  static func trackMyProfileReachCategoryPromoteButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promote, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на кнопку Payment summary
  static func trackMyProfileReachCategoryPaymentSummaryButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.paymentSummary, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на кнопку Promote в попапі Payment summary
  static func trackMyProfileReachCategoryPaymentSummaryPromoteButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.paymentSummary, element: Event.Element.promoteButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Закриття попапа Payment summary
  static func trackMyProfileReachCategoryPaymentSummaryCloseButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.paymentSummary, element: Event.Element.closeButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Натиснення на хрестик над кнопкою Promote
  static func trackMyProfileReachCategoryPromoteCloseButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promote, element: Event.Element.closeButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  У попапі Discard Promotion settings клік на кнопку Discard
  static func trackMyProfileReachCategoryDiscardPromotionDiscardButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.discardPromotion, element: Event.Element.discardButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  У попапі Discard Promotion settings клік на кнопку Go back
  static func trackMyProfileReachCategoryDiscardPromotionGoBackButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.discardPromotion, element: Event.Element.goBackButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Закрити попап Discard Promotion Settings
  static func trackMyProfileReachCategoryDiscardPromotionCloseButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.discardPromotion, element: Event.Element.closeButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Перегляд ползунка з вибором бюджета на рекламу для всіх оголошень
  static func trackMyProfileReachCategoryPromotionAllAdsAllView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promotionAllAds, element: Event.Element.all, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на 3 точки справа від ползунка з вибором бюджета на рекламу для всіх оголошень
  static func trackMyProfileReachCategoryPromotionAllAdsPromotionSettingsTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promotionAllAds, element: Event.Element.promotionSettings, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Закриття попапа Promotion settings
  static func trackMyProfileReachCategoryPromotionSettingsCloseButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promotionSettings, element: Event.Element.closeButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  На попапі promotion_settings натиснути кнопку Stop Promotion
  static func trackMyProfileReachCategoryPromotionSettingsStopPromotionButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.promotionSettings, element: Event.Element.stopPromotionButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Натиснення Stop promotion на попапі Confirm stop promotion
  static func trackMyProfileReachCategoryConfirmStopPromotionStopPromotionButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.confirmStopPromotion, element: Event.Element.stopPromotionButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Натиснення keep promotion
  static func trackMyProfileReachCategoryConfirmStopPromotionKeepPromotionButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.confirmStopPromotion, element: Event.Element.keepPromotionButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Закриття попапа Confirm stop promotion
  static func trackMyProfileReachCategoryConfirmStopPromotionCloseButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.reachCategory, section: Event.Section.confirmStopPromotion, element: Event.Element.closeButton, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}


// MARK: - Posting category search
extension EventsTracker {
  
  static func trackCategorySearchFiltersButtonTap(from screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.categorySearch, section: Event.Section.filters, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCategorySearchListQueryApply(advertisement: EventAdvertisementProtocol, screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.categorySearch, section: Event.Section.list, element: Event.Element.query, action: Event.Action.apply, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCategorySearchErrorEmptyResultsView(from screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.categorySearch, section: Event.Section.error, element: Event.Element.emptyResults, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}

// MARK: - Donate
extension EventsTracker {
  
  static func trackHomeLandingDonateMoneyButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.landing, section: Event.Section.donateMoney, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackHomeLandingDonateProductsButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.landing, section: Event.Section.donateProducts, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackHomeLandingSectionButtonTap(_ section: Event.Section) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.landing, section: section, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  static func trackDonationDonationDonationCloseTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.donation, component: Event.Component.donation, section: Event.Section.donation, element: Event.Element.close, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackDonationPriceDonateButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.donation, component: Event.Component.price, section: Event.Section.donate, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}

// Freedom onboarding
extension EventsTracker {
  
  static func trackHomeInfoMoreButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.info, section: Event.Section.more, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // event_details: country_id:id  - страна на которую переходят
  static func trackHomeInfoCountryButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.info, section: Event.Section.country, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackHomeInfoCountryButtonBack() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.home, component: Event.Component.info, section: Event.Section.country, element: Event.Element.button, action: Event.Action.back)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}

// MARK: - Freedom supplier flow
extension EventsTracker {
  // Puprpose
  static func trackScreenSupplierSectionElementView(screen: Event.Screen, section: Event.Section, element: Event.Element, parameters: [EventDetailsParameter] = []) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.supplier, section: section, element: element, action: Event.Action.view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackFormSupplierCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.form, component: Event.Component.supplier, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // Stories
  static func trackSupplierStoriesPageScreenView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.supplier, component: Event.Component.stories, section: Event.Section.page, element: Event.Element.screen, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackSupplierStoriesCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.supplier, component: Event.Component.stories, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // Delivery method
  static func trackDeliveryMethodSupplierMethodButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.deliveryMethod, component: Event.Component.supplier, section: Event.Section.method, element: Event.Element.button, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackDeliveryMethodSupplierCloseButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.deliveryMethod, component: Event.Component.supplier, section: Event.Section.close, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackDeliveryMethodSupplierButtonLinkTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.deliveryMethod, component: Event.Component.supplier, section: Event.Section.button, element: Event.Element.link, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // Supplier flow
  static func trackScreenSupplierFormFormView(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.supplier, section: Event.Section.form, element: Event.Element.form, action: Event.Action.view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenSupplierBackButtonTap(screen: Event.Screen) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.supplier, section: Event.Section.back, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenSupplierButtonElementTap(screen: Event.Screen, element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.supplier, section: Event.Section.button, element: element, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenSupplierOfferInformationFormTap(screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.supplier, section: Event.Section.offerInformation, element: Event.Element.form, action: Event.Action.tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // My shipments
  static func trackMyProfileSupplierOrderOrderElementAction(element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.supplierOrder, section: Event.Section.order, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenListingSectionAdAction(advertisement: EventAdvertisementProtocol?, screen: Event.Screen, section: Event.Section, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.listing, section: section, element: Event.Element.ad, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  // My orders
  static func trackMyProfileComponentOrderTabTap(component: Event.Component) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: component, section: Event.Section.order, element: Event.Element.tab, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyProfileBuyerOrderOrderOrderAction(action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.myProfile, component: Event.Component.buyerOrder, section: Event.Section.order, element: Event.Element.order, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}

// MARK: - Freedom limit
extension EventsTracker {
  
  static func trackFreedomLimitFreedomLimitFreedomLimitScreenView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .freedomLimit, component: .freedomLimit, section: .freedomLimit, element: .screen, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackFreedomLimitCategoryLimitsCategoryMenuElementTap(element: Event.Element, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .freedomLimit, component: .categoryLimits, section: .categoryMenu, element: element, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
    
  static func trackAdFreedomLimitLimitTypeAdView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ad, component: .freedomLimit, section: .limitType, element: .ad, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAdFreedomLimitLimitBannerButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ad, component: .freedomLimit, section: .limitBanner, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackAdFreedomLimitReplaceThingButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ad, component: .freedomLimit, section: .replaceThing, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackReplaceThingFreedomLimitErrorErrorView() {
    let eventDetails: EventDetails = EventDetails(screen: .replaceThing, component: .freedomLimit, section: .error, element: .error, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackReplaceThingFreedomLimitAdButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .replaceThing, component: .freedomLimit, section: .ad, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackReplaceThingFreedomLimitReplaceButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .replaceThing, component: .freedomLimit, section: .replace, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackReplaceThingFreedomLimitReplacePopupButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .replaceThing, component: .freedomLimit, section: .replacePopup, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackReplaceThingFreedomLimitReplacePopupButtonClose() {
    let eventDetails: EventDetails = EventDetails(screen: .replaceThing, component: .freedomLimit, section: .replacePopup, element: .button, action: .close)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Loyalty
  static func trackMyProfileLoyaltyAccountMenuBannerTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .loyaltyAccount, section: .menu, element: .banner, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyProfileLoyaltyAccountMenuButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .loyaltyAccount, section: .menu, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLoyaltySystemCardsButtonView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .cards, element: .button, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLoyaltySystemCardsButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .cards, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLimitScreenLoyaltySystemButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .limitScreen, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  static func trackLoyaltyLoyaltySystemHeaderOnboardingTap() {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .header, element: .onboarding, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLoyaltySystemCardsOnboardingTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .cards, element: .onboarding, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLoyaltySystemListLinkTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .list, element: .link, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyPostingCardsButtonView() {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .posting, section: .cards, element: .button, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyPostingCardsButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .posting, section: .cards, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyOnboardingCardsButtonView() {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .onboarding, section: .cards, element: .button, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyOnboardingCardsButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .onboarding, section: .cards, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyReplenishLoyaltySystemPricePriceLabelView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyaltyReplenishment, component: .loyaltySystem, section: .price, element: .priceLabel, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyReplenishLoyaltySystemPriceButtonView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyaltyReplenishment, component: .loyaltySystem, section: .price, element: .button, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyReplenishLoyaltySystemPriceButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyaltyReplenishment, component: .loyaltySystem, section: .price, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyReplenishLoyaltySystemPriceOnboardingTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyaltyReplenishment, component: .loyaltySystem, section: .price, element: .onboarding, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyReplenishLoyaltySystemPriceLinkTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyaltyReplenishment, component: .loyaltySystem, section: .price, element: .link, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLoyaltySystemListQuestionSelect(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .list, element: .question, action: .select, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLoyaltyLoyaltySystemCallBackButtonTap(parameters: [EventDetailsParameter]) -> EventModel {
    let eventDetails: EventDetails = EventDetails(screen: .loyalty, component: .loyaltySystem, section: .callBack, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
    return event
  }
  
  static func trackLoyaltyReplenishmentLoyaltySystemPromotionButtonTap(){
    let eventDetails: EventDetails = EventDetails(
      screen: .loyaltyReplenishment,
      component: .loyaltySystem,
      section: .promotion,
      element: .button,
      action: .tap
    )
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  static func trackLoyaltyReplenishmentLoyaltySystemCallbackButtonTap(_ parameters: [EventDetailsParameter]) -> EventModel {
    let eventDetails: EventDetails = EventDetails(
      screen: .loyaltyReplenishment,
      component: .loyaltySystem,
      section: .callBack,
      element: .button,
      action: .tap,
      details: Event.Details.defined(parameters)
    )
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
    return event
  }
  
  
  static func trackScreenStoriesPageScreenView(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: .stories, section: .page, element: .screen, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenLoyaltySystemPageNotificationView(_ screen: Event.Screen, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: .loyaltySystem, section: .page, element: .notification, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVLoyaltySystemLoyaltySystemOnboardingTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .loyaltySystem, section: .loyaltySystem, element: .onboarding, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVPayLoyaltySystemButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .pay, section: .loyaltySystem, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVPayLoyaltySystemButtonView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .pay, section: .loyaltySystem, element: .button, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackWalletLoyaltySystemDiscountButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .wallet, component: .loyaltySystem, section: .discount, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyAdLoyaltyAccountUpgradeProfileButtonView(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myAd, component: .loyaltyAccount, section: .upgradeProfile, element: .button, action: .view, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMyAdLoyaltyAccountUpgradeProfileButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myAd, component: .loyaltyAccount, section: .upgradeProfile, element: .button, action: .tap, details: .defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackLalafoBusinessLoyaltySystemHeaderBannerTap() {
    let eventDetails: EventDetails = EventDetails(screen: .lalafoBusiness, component: .loyaltySystem, section: .header, element: .banner, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Failed payment feedback
  /// просмотр экрана:
  static func trackPaymentFeedbackPaymentButtonView() {
    let eventDetails: EventDetails = EventDetails(screen: .payment, component: .feedback, section: .payment, element: .button, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// тап на фидбек - event_details: comment: ""
  static func trackPaymentFeedbackPaymentButtonTap(parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .payment, component: .feedback, section: .payment, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  /// закрытие через одну из кнопок
  static func trackPaymentFeedbackPaymentButtonClose() {
    let eventDetails: EventDetails = EventDetails(screen: .payment, component: .feedback, section: .payment, element: .button, action: .close)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - CSAT feedback  
  static func trackScreenFeedbackListingElementAction(screen: Event.Screen, element: Event.Element, action: Event.Action, advertisement: Advertisement?, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: .feedback, section: .listing, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackScreenFeedbackFeedbackButtonTap(screen: Event.Screen, advertisement: Advertisement?, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: .feedback, section: .feedback, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Multiposting
  static func trackMultipostingMultipostGenerateDescriptionButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .generateDescription, element: .button, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMultipostingMultipostOnboardingMultipostingHintTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .onboarding, element: .multipostingHint, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMultipostingMultipostTabBarPostingTapbTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .tabBar, element: .postingTab, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMultipostingMultipostTabBarMultipostingTabTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .tabBar, element: .multipostingTab, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMultipostingMultipostGenerateDescriptionButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .generateDescription, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMultipostingMultipostAdsPublicationAdView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .ad, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackMultipostingMultipostAdsPublicationButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

  // MARK: - Complex Purchase v2
//  Перегляд плашки з фільтрами у профілі (лише перший перегляд на сторінці)  https://imgur.com/a/aHAgVK4  view  all  my_profile  top_filters  search  all  view
  static func trackMyProfileTopFiltersSearchAllView() {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .topFilters, section: .search, element: .all, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на конкретний фільтр у профілі  https://imgur.com/a/zfUCRGM  tap  all  my_profile  top_filters  search  button  select  {”selected_parameter”: "category" | "status | "promotion" | "sort_by"" }
  static func trackMyProfileTopFiltersSearchButtonSelect(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .topFilters, section: .search, element: .button, action: .select, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
//  Вибір значення у конкретному фільтрі  https://imgur.com/a/FtrALG7  select  all  my_profile  top_filters  search  button  tap  "ONLY ONE OF:
//  {""category"": {category_id}}
//  {""status"": active | unpaid | moderation }
//  {""sort_by"": newest | -newest | price | -price}
//  {""promotion"": paid | unpaid}"
  static func trackMyProfileTopFiltersSearchButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .topFilters, section: .search, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }

//  Перегляд кнопки для переходу у архів "Архів" (лише перший перегляд на сторінці)  https://imgur.com/a/L3wBOpO  view  all  my_profile  archive  archive_button  button  view  cnt_ads: кількість оголошень у архіві користувача
  static func trackMyProfileArchiveButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .archive, section: .archiveButton, element: .button, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на кнопку для переходу у "Архів"  як у 4  tap  all  my_profile  archive  archive_button  button  tap  cnt_ads: кількість оголошень у архіві користувача
  static func trackMyProfileArchiveButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .archive, section: .archiveButton, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік "Select All" у профілі  думаю інтуїтивно зрозуміло  tap  all  my_profile  selected_ads  select_all  button  tap
  static func trackMyProfileSelectedAdsSelectAllButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .selectedAds, section: .selectAll, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  tap  all  my_profile  selected_ads  deselect_all  button  tap
  static func trackMyProfileSelectedAdsDeselectAllButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .selectedAds, section: .deselectAll, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік кнопки "Promote" у профілі  https://imgur.com/a/z0BXV3I  tap  all  my_profile  mass_ppv  activate  button  tap  "cnt_ads: кількість оголошень
//  category:category_id
//  ""status"": active | unpaid | moderation
//  ""sort_by"": newest | -newest | price | -price
//  ""promotion"": paid | unpaid"
  static func trackMyProfileMassPpvActivateButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .massPpv, section: .activate, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Перегляд кнопки "Promote" на екрані Promotion  https://imgur.com/a/DHTmO8g  view  all  mass_ppv  mass_ppv  advertise_button  button  view  "cnt_ads: кількість оголошень
//  start_budget: '132' - дефолтний тотальний бюджет у локальній валюті"
  static func trackMassPpvAdvertiseButtonButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .massPpv, component: .massPpv, section: .advertiseButton, element: .button, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік кнопки "Promote" на екрані Promotion  як у 9  tap  all  mass_ppv  mass_ppv  advertise_button  button  tap  "cnt_ads: кількість оголошень 
//  status: статус після натиснення кнопки (УТОЧНЕННЯ АЛЕ СКОРІШЕ ЗА ВСЕ НЕМАЄ)
//  final_budget: '132' - фіннальний тотальний бюджет у локальній валюті"
  static func trackMassPpvAdvertiseButtonButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .massPpv, component: .massPpv, section: .advertiseButton, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Перегляд плашки з фільтрами у архіві  аналогічно як 1 просто у архіві  view  all  archieve  top_filters  search  all  view
  static func trackArchieveTopFiltersSearchAllView() {
    let eventDetails: EventDetails = EventDetails(screen: .archieve, component: .topFilters, section: .search, element: .all, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік на конкретний фільтр у архіві  аналогічно як 2 просто у архіві  tap  all  archieve  top_filters  search  button  select  {”selected_parameter”: "category" | "status | "promotion" | "sort_by"" }
  static func trackArchieveTopFiltersSearchButtonSelect(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .archieve, component: .topFilters, section: .search, element: .button, action: .select, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Вибір значення у конкретному фільтрі у архіві  аналогічно як 3 просто у архіві  select  all  archieve  top_filters  search  button  tap  "ONLY ONE OF:
//  {""category"": {category_id}}
//  {""status"": deactivated | rejected }
//  {""sort_by"": newest | -newest | price | -price}
//  {""promotion"": paid | unpaid}"
  static func trackArchieveTopFiltersSearchButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .archieve, component: .topFilters, section: .search, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік "Select All" у архіві  аналогічно як 6 просто у архіві  tap  all  archieve  selected_ads  select_all  button  tap
  static func trackArchieveSelectedAdsSelectAllButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .archieve, component: .selectedAds, section: .selectAll, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік "Deselect All" у архіві  аналогічно як 7 просто у архіві  tap  all  archieve  selected_ads  deselect_all  button  tap
  static func trackArchieveSelectedAdsDeselectAllButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .archieve, component: .selectedAds, section: .deselectAll, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік кнопки "Promote" у архіві  аналогічно як 8 просто у архіві  tap  all  archieve  mass_ppv  activate  button  tap  """cnt_ads: кількість оголошень
//  category:category_id
//  """"status"""": deactivated | rejected
//  """"sort_by"""": newest | -newest | price | -price
//  """"promotion"""": paid | unpaid"""
  static func trackArchieveMassPpvActivateButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .archieve, component: .massPpv, section: .activate, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  Клік кнопки для архівації оголошень  https://imgur.com/a/5R4bpcR  tap  all  my_profile  archivate  archivate_button  button  tap  """cnt_ads: кількість оголошень
//  category:category_id
//  """"status"""": deactivated | rejected
//  """"sort_by"""": newest | -newest | price | -price
//  """"promotion"""": paid | unpaid"""
  static func trackMyProfileArchivateButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .archivate, section: .archivateButton, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  ppv  tab_bar  tab_bar  all  view  "category_id - ID категорії reach category
  //  flow_id - перевикористати з ppv флоу"
  static func trackPPVTabBarTabBarAllView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .tabBar, section: .tabBar, element: .all, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  //  ppv  tab_bar  tab_bar  for_ad  tap
  static func trackPPVTabBarTabBarForAdTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .tabBar, section: .tabBar, element: .forAd, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  //  ppv  tab_bar  tab_bar  for_category  tap
  static func trackPPVTabBarTabBarForCategoryTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .tabBar, section: .tabBar, element: .forCategory, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  ppv  reach_category  "reach_category_advertise_button - якщо потрапили НЕ з флоу постінга
//  reach_category_after_posting - якщо потрапили з флоу постінга
//  reach_category_update_button - якщо потрапили НЕ з флоу постінга + річ категорі вже був у юзера на оголошенні"  button  view
  static func trackPPVReachCategoryReachCategoryAdvertiseButtonView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .reachCategoryAdvertiseButton, element: .button, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVReachCategoryReachCategoryAfterPostingView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .reachCategoryAfterPosting, element: .button, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVReachCategoryReachCategoryAdvertiseButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .reachCategoryAdvertiseButton, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackPPVReachCategoryReachCategoryAfterPostingTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .reachCategoryAfterPosting, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  ppv  reach_category  usp  unlimited_ads  tap
  static func trackPPVReachCategoryUSPUnlimitedAdsTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .usp, element: .unlimitedAds, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  ppv  reach_category  usp  promotion_all_ads  tap
  static func trackPPVReachCategoryUSPPromotionAllAdsTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .usp, element: .promotionAllAds, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  ppv  reach_category  usp  promotion_facebook  tap
  static func trackPPVReachCategoryUSPPromotionFacebookTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .usp, element: .promotionFacebook, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  ppv  reach_category  usp  pro_badge  tap
  static func trackPPVReachCategoryUSPProBadgeTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .ppv, component: .reachCategory, section: .usp, element: .proBadge, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  my_profile  reach_category  category_promotion  tile  view
  static func trackMyProfileReachCategoryCategoryPromotionTileView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .reachCategory, section: .categoryPromotion, element: .tile, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  my_profile  reach_category  category_promotion  button  tap
  static func trackMyProfileReachCategoryCategoryPromotionButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .reachCategory, section: .categoryPromotion, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  my_profile  reach_category  stop_category_promotion  stop_button  tap
  static func trackMyProfileReachCategoryStopCategoryPromotionStopButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .reachCategory, section: .stopCategoryPromotion, element: .stopButton, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
//  my_profile  reach_category  stop_category_promotion  continue_button  tap
  static func trackMyProfileReachCategoryStopCategoryPromotionContinueButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .myProfile, component: .reachCategory, section: .stopCategoryPromotion, element: .continueButton, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:gallery:multipost:photo:add
  static func trackMultipostingMultipostGalleryPhotoAdd() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .gallery, element: .photo, action: .add)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ad_list:ad:select
  static func trackMultipostingMultipostAdListAdSelect() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adList, element: .ad, action: .select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:popup:button:view
  static func trackMultipostingMultipostPopupButtonView() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .popUp, element: .button, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:popup:button:tap
  static func trackMultipostingMultipostPopupButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .popUp, element: .button, action: .tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:popup:error:view
  static func trackMultipostingMultipostPopupErrorView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .popUp, element: .error, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:generation:popup:view
  static func trackMultipostingMultipostGenerationPopupView() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .generation, element: .popUp, action: .view)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:generation:button:tap
  static func trackMultipostingMultipostGenerationButtonTap(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .generation, element: .button, action: .tap, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:ad:delete
  static func trackMultipostingMultipostAdsPublicationAdDelete() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .ad, action: .delete)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:photo:remove
  static func trackMultipostingMultipostAdsPublicationPhotoRemove() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .photo, action: .remove)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:photo:add
  static func trackMultipostingMultipostAdsPublicationPhotoAdd() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .photo, action: .add)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:category:select
  static func trackMultipostingMultipostAdsPublicationCategorySelect() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .category, action: .select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:price:select
  static func trackMultipostingMultipostAdsPublicationPriceSelect() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .price, action: .select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:currency:select
  static func trackMultipostingMultipostAdsPublicationCurrencySelect() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .currency, action: .select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:description:select
  static func trackMultipostingMultipostAdsPublicationDescriptionSelect() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .description, action: .select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:param:select
  static func trackMultipostingMultipostAdsPublicationParamSelect() {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .param, action: .select)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // multiposting:multipost:ads_publication:error:view
  static func trackMultipostingMultipostAdsPublicationErrorView(_ parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: .multiposting, component: .multipost, section: .adsPublication, element: .error, action: .view, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  // MARK: - Single Posting Events
  static func trackPostingAddItemPostButtonView() {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.addItem,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.view
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAddItemPostButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.addItem,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAddItemPostErrorView(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.addItem,
          component: Event.Component.post,
          element: Event.Element.error,
          action: Event.Action.view,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingGenerationPostPopupView() {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.generation,
          component: Event.Component.post,
          element: Event.Element.popup,
          action: Event.Action.view
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingGenerationPostPopupTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.generation,
          component: Event.Component.post,
          element: Event.Element.popup,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingTutorialPostButtonTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.tutorial,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingTutorialPostButtonView(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.tutorial,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.view,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostAdView(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.ad,
          action: Event.Action.view,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingParamPostFieldSelect(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.param,
          component: Event.Component.post,
          element: Event.Element.field,
          action: Event.Action.select,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostPriceSelect(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.price,
          action: Event.Action.select,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostDescriptionSelect(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.description,
          action: Event.Action.select,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingGalleryPostPhotoAdd(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.gallery,
          component: Event.Component.post,
          element: Event.Element.photo,
          action: Event.Action.add,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingBasicPostCategorySelect(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.basic,
          component: Event.Component.post,
          element: Event.Element.category,
          action: Event.Action.select,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingErrorCategorySearchEmptyResultsView(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.error,
          component: Event.Component.categorySearch,
          element: Event.Element.emptyResults,
          action: Event.Action.view,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingListCategorySearchQueryApply(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.list,
          component: Event.Component.categorySearch,
          element: Event.Element.query,
          action: Event.Action.apply,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostPopupTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.popup,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostPopupView(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.popup,
          action: Event.Action.view,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostErrorTap(parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.error,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

  static func trackPostingAdsPublicationPostButtonTap(parameters: [EventDetailsParameter], label: String) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.posting,
          section: Event.Section.adsPublication,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.tap,
          label: Event.Label.defined(label),
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(with: eventDetails)
      trackEvent(event: event)
  }

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

//  static func trackMyAdBoostPhotoPostButtonView(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
//      let eventDetails: EventDetails = EventDetails(
//          screen: Event.Screen.myAd,
//          section: Event.Section.boostPhoto,
//          component: Event.Component.post,
//          element: Event.Element.button,
//          action: Event.Action.view,
//          details: .defined(parameters)
//      )
//      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
//      trackEvent(event: event)
//  }

//  static func trackMyAdBoostPhotoPostButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
//      let eventDetails: EventDetails = EventDetails(
//          screen: Event.Screen.myAd,
//          section: Event.Section.boostPhoto,
//          component: Event.Component.post,
//          element: Event.Element.button,
//          action: Event.Action.tap,
//          details: .defined(parameters)
//      )
//      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
//      trackEvent(event: event)
//  }

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

//  static func trackMyAdGenerationPostPopupTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
//      let eventDetails: EventDetails = EventDetails(
//          screen: Event.Screen.myAd,
//          section: Event.Section.generation,
//          component: Event.Component.post,
//          element: Event.Element.popup,
//          action: Event.Action.tap,
//          details: .defined(parameters)
//      )
//      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
//      trackEvent(event: event)
//  }

  static func trackAiPhotoEnhancementFollowupPopupPostButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
      let eventDetails: EventDetails = EventDetails(
          screen: Event.Screen.aiPhotoEnhancementFollowup,
          section: Event.Section.popUp,
          component: Event.Component.post,
          element: Event.Element.button,
          action: Event.Action.tap,
          details: .defined(parameters)
      )
      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
      trackEvent(event: event)
  }

//  static func trackAiPhotoEnhancementFollowupPopupPostButtonTap(advertisement: EventAdvertisementProtocol, parameters: [EventDetailsParameter]) {
//      let eventDetails: EventDetails = EventDetails(
//          screen: Event.Screen.aiPhotoEnhancementFollowup,
//          section: Event.Section.popUp,
//          component: Event.Component.post,
//          element: Event.Element.button,
//          action: Event.Action.tap,
//          details: .defined(parameters)
//      )
//      let event: EventModel = EventFactory.event(for: advertisement, with: eventDetails)
//      trackEvent(event: event)
//  }
}

// MARK: - Feed elements
extension EventsTracker {
  static func trackCustomElementsSectionElementAction(screen: Event.Screen, section: Event.Section, element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.customElements, section: section, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    
    // It's workaround for custom feed elements https://yallaclassifieds.atlassian.net/browse/DV-28540
    if let categoryParameter = parameters.first(where: { $0.key == Constants.EventDetails.categoryId }),
       let categoryId = Int(categoryParameter.value) {
      event.setCategoryId(categoryId)
    }
    trackEvent(event: event)
  }
}

// MARK: - Buyer bonuses
extension EventsTracker {
  static func trackScreenBuyerBonusesSectionElementAction(screen: Event.Screen, section: Event.Section, element: Event.Element, action: Event.Action, parameters: [EventDetailsParameter]) {
    let eventDetails: EventDetails = EventDetails(screen: screen, component: Event.Component.buyerBonuses, section: section, element: element, action: action, details: Event.Details.defined(parameters))
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackSuccessWindowCartViewCartButtonTap() {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.successWindow, component: Event.Component.cart, section: Event.Section.viewCart, element: Event.Element.button, action: Event.Action.tap)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}


// MARK: - Ordering goods flow
extension EventsTracker {
  static func trackCartComponentClosingConfirmationElementAction(component: Event.Component, element: Event.Element, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: component, section: Event.Section.closingConfirmation, element: element, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
  
  static func trackCartFeedbackFeedbackElementAction(element: Event.Element, action: Event.Action) {
    let eventDetails: EventDetails = EventDetails(screen: Event.Screen.cart, component: Event.Component.feedback, section: Event.Section.feedback, element: element, action: action)
    let event: EventModel = EventFactory.event(with: eventDetails)
    trackEvent(event: event)
  }
}
