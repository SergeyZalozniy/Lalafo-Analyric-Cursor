//
//  EventDetails.swift
//  Lalafo
//
//  Created by Anton Ivashyna on 07/09/2017.
//  Copyright © 2017 Yallaclassified. All rights reserved.
//

import Foundation

protocol EventTrackable {
  var name: String { get }
}

struct Event {
  // MARK: - Client
  enum Client: String, EventTrackable {
    case unknown
    case ios = "ios"

    var name: String {
      return rawValue
    }
  }

  // MARK: - Screen
  enum Screen: String, EventTrackable {
    case unknown

    case ad
    case activationForm = "activation_form"
    case aiPhotoEnhancementFollowup = "ai_photo_enhancement_followup"
    case archieve
    case autoReplenishment = "auto_replenishment"
    case authorization
    case buyerOrder = "buyer_order"
    case callValidation = "call_validation"
    case cart
    case chatList = "chat_list"
    case country
    case cvBuilder = "cvbuilder"
    case cvList = "cv_list"
    case customFeed = "custom_feed"
    case сreatePassword = "сreate_password"
    case donation
    case deliveryMethod = "delivery_method"
    case deepLink = "deep_link"
    case editAdvertisement = "edit_ad"
    case editProfile = "edit_profile"
    case editProProfile = "edit_pro_profile"
    case efficiency
    case favorites
    case fastMessage = "fast_message"
    case feedback
    case filters
    case freedomLimit = "freedom_limit"
    case form
    case greetingsMessage = "greetings_message"
    case home
    case improveProfile = "improve_profile"
    case inviteFriends = "invite_friends"
    case information
    case itemList = "item_list"
    case lalafoBusiness = "lalafo_business"
    case language
    case listing
    case listingMap = "listing_map"
    case login
    case loyalty
    case loyaltyReplenishment = "loyalty_replenishment"
    case manageProfile = "manage_profile"
    case massPpv = "mass_ppv"
    case multiposting
    case modal
    case myAd = "my_ad"
    case myProfile = "my_profile"
    case myProfileBp = "my_profile_bp"
    case myOrder = "my_order"
    case notification
    case notifications
    case offerInformation = "offer_information"
    case onboarding
    case payment
    case posting
    case postingSuccess = "posting_success"
    case ppv = "ppv"
    case ppvBP = "ppv_bp"
    case proAccount = "pro_account"
    case proContact = "pro_contact"
    case promocode = "promo_code"
    case proUserProfile = "pro_user_profile"
    case purchaseChat = "purchase_chat"
    case phoneConfirmation = "phone_confirmation"
    case rateUs = "rate_us"
    case recommended
    case recovery
    case registration
    case replaceThing = "replace_thing"
    case saleChat = "sale_chat"
    case settings
    case sendForm = "send_form"
    case serviceFeeInfo = "service_fee_info"
    case smsValidation = "sms_validation"
    case splash
    case statistics
    case support
    case supplier
    case successWindow = "success_window"
    case tips
    case thankYou = "thank_you"
    case userProfile = "user_profile"
    case utpScreen = "utp_screen"
    case vas
    case wallet
    case walletBp = "wallet_bp"
    case withdrawForm = "withdraw_form"

    var name: String {
      return rawValue
    }
  }
  // MARK: - Component
  enum Component: String, EventTrackable {
    case unknown

    case activation
    case ad
    case allSellerItems = "all_seller_items"
    case applyJob = "apply_job"
    case archivate
    case archive
    case authorization
    case autocart
    case autoReplenishment = "auto_replenishment"
    case banner
    case back
    case boughtAlert = "bought_alert"
    case bp = "BP"
    case bpInfo = "bp_info"
    case buyerBonuses = "buyer_bonuses"
    case buyerOrder = "buyer_order"
    case cart
    case cartFeed = "cart_feed"
    case categorySearch = "category_search"
    case categoryLimits = "category_limits"
    case chat
    case confirmation
    case confirmationScreen = "confirmation_screen"
    case contact
    case contacts
    case courier
    case close
    case сreatePassword = "сreate_password"
    case customElements = "custom_elements"
    case deactivate
    case description
    case details
    case donation
    case edit
    case efficiency
    case editProfile = "edit_profile"
    case emptyResult = "empty_result"
    case favorites
    case fastMessage = "fast_message"
    case feedback
    case feedBanner = "feed_banner"
    case freedomLimit = "freedom_limit"
    case fondy
    case form
    case freeVas = "free_vas"
    case googleBanner = "google_banner"
    case greetingsMessage = "greetings_message"
    case info
    case inviteFriends = "invite_friends"
    case impressions
    case image
    case landing
    case listing
    case location
    case loyaltyAccount = "loyalty_account"
    case loyaltySystem = "loyalty_system"
    case login
    case map
    case massDeactivation = "mass_deactivation"
    case massDeletion = "mass_deletion"
    case massPpv = "mass_ppv"
    case menu
    case multipost
    case numberUpdate = "number_update"
    case onboarding
    case order3hAlert = "order3h_alert"
    case pay
    case push
    case post
    case posting
    case postBP = "post_bp"
    case ppv
    case ppvBP = "ppv_bp"
    case ppvInfo = "ppv_info"
    case price
    case proAccount = "pro_account"
    case proAccountContacts = "pro_account_contacts"
    case profile
    case promocode = "promo_code"
    case purchase
    case reachCategory = "reach_category"
    case recommended
    case recovery
    case refugeeConfirmation = "refugee_confirmation"
    case report
    case registration
    case search
    case searchMap = "search_map"
    case settings
    case selectedAds = "selected_ads"
    case share
    case statisticsInfo = "statistics_info"
    case stories
    case subscription
    case supplier
    case supplierOrder = "supplier_order"
    case tabBar = "tab_bar"
    case taps
    case topFilters = "top_filters"
    case thankYouPage = "thank_you_page"
    case utp
    case vas
    case vasBp = "vas_bp"
    case verificationOldUser = "verification_old_user"
    case wallet
    case walletAfterPPV = "wallet_after_ppv"
    case walletRecommended = "wallet_recommended"
    case withdrawForm = "withdraw_form"

    var name: String {
      return rawValue
    }
  }

  // MARK: - Section
  enum Section: String, EventTrackable {
    case unknown
    case alternative
    case allDetails = "all_details"
    case aboutMetrics = "about_metrics"
    case activate
    case ad
    case addCode = "add_code"
    case addItem = "add_item"
    case addFastMessage = "add_fast_message"
    case addMessage = "add_message"
    case adList = "ad_list"
    case adsPublication = "ads_publication"
    case advertiseButton = "advertise_button"
    case advertiseButtonFree = "advertise_button_free"
    case advertiseStop = "advertise_stop"
    case apply
    case archiveButton = "archive_button"
    case archivateButton = "archivate_button"
    case autoReplenishment = "auto_replenishment"
    case authorization = "authorization"
    case back
    case backButton = "back_button"
    case banner
    case basic
    case boostPhoto = "boost_photo"
    case bp = "BP"
    case bpUrl = "bp_url"
    case bpSocial = "bp_social"
    case bpContacts = "bp_contacts"
    case bpWorkhours = "bp_workhours"
    case bpBranding = "bp_branding"
    case bpPhotogallery = "bp_photogallery"
    case bpBanner = "bp_banner"
    case bpGreetingsMessage = "bp_greetings_message"
    case budgetDuration = "budget_duration"
    case buyFeature = "buy_feature"
    case buyNow = "buy_now"
    case buyerOrder = "buyer_order"
    case button
    case cartButton = "cart_button"
    case city
    case confirm
    case confirmationScreen = "confirmation_screen"
    case confirmStopPromotion = "confirm_stop_promotion"
    case createdOrderPurpose = "created_order_purpose"
    case error
    case errorWindow = "error_window"
    case emptyButton = "empty_button"
    case emailOrPhone = "email_phone"
    case call
    case callBack = "callback"
    case camera
    case cards
    case categoryDecreasedBanner = "category_decreased_banner"
    case categoryIncreasedBanner = "category_increased_banner"
    case categoryPromotion = "category_promotion"
    case categorySpeedup = "category_speedup"
    case categoryTab = "category_tab"
    case categoryMenu = "category_menu"
    case categoryOpen = "category_open"
    case chat
    case chatList = "chat_list"
    case close
    case closingConfirmation = "closing_confirmation"
    case country
    case courier
    case cvCreate = "cv_create"
    case cvSend = "cv_send"
    case currency
    case date
    case deepLink = "deep_link"
    case deactivate
    case delete
    case deleteAll = "delete_all"
    case deselectAll = "deselect_all"
    case description
    case discardPromotion = "discard_promotion"
    case discount
    case donationAds = "donation_ads"
    case donateMoney = "donatemoney"
    case donateProducts = "donateproducts"
    case donate
    case donation
    case duplicate
    case edit
    case editAd = "edit_ad"
    case editCampaign = "edit_campaign"
    case efficiency
    case email
    case extend
    case facebook
    case favorites
    case feed
    case feedback
    case fields
    case filters
    case freeBanner = "free_banner"
    case freeLimit = "free_limit"
    case freedomLimit = "freedom_limit"
    case form
    case gallery
    case generateDescription = "generate_description"
    case generation
    case gotIt = "got_it"
    case header
    case history
    case home
    case homeHeaderBanner = "home_header_banner"
    case infoBlock = "info_block"
    case information
    case input
    case landing
    case lalafoClub = "lalafo_club"
    case language
    case limitScreen = "limit_screen"
    case limitType = "limit_type"
    case limitBanner = "limit_banner"
    case link
    case list
    case listing
    case listMore = "list_more"
    case localPush = "local_push"
    case location
    case login
    case loyaltySystem = "loyalty_system"
    case makeAnOffer = "make_an_offer"
    case map
    case magicButton = "magic_button"
    case menu
    case messenger
    case method
    case methodEmail = "Email"
    case methodSMS = "SMS"
    case methodTwitter = "Twitter"
    case metrics
    case mobile
    case moderationLink = "moderation_link"
    case more
    case modalWindow = "modal_window"
    case myOrder = "my_order"
    case myAd = "my_ad"
    case notification
    case noSupport = "no_support"
    case offerInformation = "offer_information"
    case onboardingButton = "onboarding_button"
    case onboarding
    case order
    case param
    case params
    case password
    case pay
    case payment
    case paymentSummary = "payment_summary"
    case paymentURL = "payment_url"
    case pending
    case permission
    case personalInformation = "personal_information"
    case personalEmail = "personal_email"
    case personalPhone = "personal_phone"
    case phone
    case phoneConfirmation = "phone_confirmation"
    case popUp = "popup"
    case post
    case posting
    case ppv
    case ppvAfterPosting = "ppv_after_posting"
    case ppvFreeAfterPosting = "ppv_free_after_posting"
    case ppvUpdateButton = "ppv_update_button"
    case price
    case previewProfile = "preview_profile"
    case promoLabel = "promo_label"
    case promoFeed = "promo_feed"
    case proAccount = "pro_account"
    case promote
    case promotion
    case promotionAllAds = "promotion_all_ads"
    case promotionSettings = "promotion_settings"
    case profile
    case publish
    case pushUp = "push_up"
    case purpose
    case page
    case radioButton = "radio_button"
    case reachCategoryAdvertiseButton = "reach_category_advertise_button"
    case reachCategoryAfterPosting = "reach_category_after_posting"
    case recommendation
    case recommended
    case recommendationDescription = "recommendation_description"
    case recommendationParams = "recommendation_params"
    case recommendationPhoto = "recommendation_photo"
    case recovery
    case recoveryPassword = "recovery_password"
    case recycleAds = "recycle_ads"
    case resendCall = "resend_call"
    case resendSMS = "resend_sms"
    case replaceThing = "replace_thing"
    case replacePopup = "replace_popup"
    case replace
    case save
    case search
    case searchAd = "search_ad"
    case selectAll = "select_all"
    case selectInfo = "select_info"
    case selectBalance = "select_balance"
    case selectLimit = "select_limit"
    case sellingAds = "selling_ads"
    case sellFaster = "sell_faster"
    case sellFasterUpdate = "sell_faster_update_button"
    case settings
    case session
    case serviceFeeInfo = "service_fee_info"
    case similarAds = "similar_ads"
    case showAds = "show_ads"
    case showDescriptionText = "show_description_text"
    case showRecomText = "show_recom_text"
    case showMore = "showmore"
    case showLess = "showless"
    case skip
    case social
    case soldAds = "sold_ads"
    case statistics
    case status = "status"
    case statusList = "status_list"
    case stopCategoryPromotion = "stop_category_promotion"
    case systemButton = "system_button"
    case subscriptionList = "subscription_list"
    case successWindow = "success_window"
    case supplierOrder = "supplier_order"
    case splash = "splash"
    case `switch` = "switch"
    case tabBar = "tab_bar"
    case thankYouPage = "thank_you_page"
    case topFilters = "top_filters"
    case tutorial
    case twitter
    case upgrade
    case upgradeProfile = "upgrade_profile"
    case user
    case userAds = "user_ads"
    case updatesBanner = "updates_banner"
    case usp
    case vas
    case vasDPFPosting = "vas_dpf_posting"
    case vasPosting = "vas_posting"
    case vasSellFaster = "vas_sell_faster"
    case verifyProfile = "verify_profile"
    case verificationOldUser = "verification_old_user"
    case viber
    case viewCart = "view_cart"
    case volume
    case wallet
    case write
    case website = "web_site"
    case welcome
		case whatsapp
    case withdrawForm = "withdraw_form"

		var name: String {
			return rawValue
		}
	}

	// MARK: - Element
	enum Element: String, EventTrackable {
		case unknown
    
    case action
		case ad
		case adsTab = "ads_tab"
    case autoReplenishment = "auto_replenishment"
    case applyButton = "apply_button"
    case banner
    case back = "back_button"
    case all
		case button
    case buttonAction = "button_action"
    case call
    case card
    case category
		case chat
		case chatAllTab = "all_tab"
		case chatBlockedTab = "blocked_tab"
		case chatBuyingTab = "buying_tab"
		case chatSellingTab = "selling_tab"
    case chatUser = "chat_user"
		case code
    case clear
    case close
    case closeButton = "close_button"
		case chatList = "chat_list"
    case continueButton = "continue_button"
    case currency
    case description
    case discardButton = "discard_button"
    case error
    case element
		case field
		case favorites
    case forAd = "for_ad"
    case forCategory = "for_category"
    case form
    case feedBanner = "feed_banner"
    case goBackButton = "go_back_button"
		case icon
    case item
    case keepPromotionButton = "keep_promotion_button"
		case levelOne = "level_1"
		case levelTwo = "level_2"
		case levelThree = "level_3"
    case levelFour = "level_4"
		case levelDeep = "level_deep"
		case link
    case multipostingHint = "multiposting_hint"
    case multipostingTab = "multiposting_tab"
		case home
		case homeBanner = "home_banner"
		case map
		case notification
		case myProfile = "my_profile"
		case number
    case onboarding
    case onboardingForm = "onboarding_form"
    case param
    case permission
    case pin
    case photo
    case photoBoostWaitingPopup = "photo_boost_waiting_popup"
    case popup
    case popUp = "pop_up"
    case popupPage = "popup_page"
    case postingTab = "posting_tab"
    case price
    case priceLabel = "price_label"
    case proBadge = "pro_badge"
    case promoteButton = "promote_button"
    case promotionAllAds = "promotion_all_ads"
    case promotionFacebook = "promotion_facebook"
    case promotionSettings = "promotion_settings"
    case push
    case order
		case reason
    case resetAll = "reset_all"
		case facebook = "FB"
		case footerBanner = "footer_banner"
    case screen
		case slider
    case socialApple = "Apple"
		case socialGoogle = "G"
		case socialOdnoklassniki = "OK"
		case socialVkontakte = "VK"
    case sortByDate = "sort_by_data"
    case sortByUnread = "sort_by_unread"
		case searchTab = "search_tab"
    case send
    case stopButton = "stop_button"
    case stopPromotionButton = "stop_promotion_button"
		case subscription
    case tab
    case textLink = "text_link"
    case tile
    case unlimitedAds = "unlimited_ads"
		case query
    case queryHistory = "query_history"
		case querySuggestion = "query_suggestion"
    case question
		case emptyResults = "empty_results"
    case window

		var name: String {
			return rawValue
		}
	}

	// MARK: - Action
	enum Action: String, EventTrackable {
		case unknown

		case add
		case addFavorite = "add_favorite"
		case apply
		case autoSelect = "auto_select"
    case back
		case call
		case chat
    case close
    case copy
		case delete
		case deleteAll = "delete_all"
		case edit
    case error
		case input
		case open
    case pull
    case remove
		case removeFavorite = "remove_favorite"
		case remindLater = "remind_later"
		case retrySendImage = "retry_send_image"
		case retrySendMessage = "retry_send_message"
    case select
    case selectAd = "select_ad"
    case sendImage = "send_image"
    case sendMessage = "send_message"
    case sendOffer = "send_offer"
    case sendPreparedMessage = "send_prepared_message"
    case skip
		case sms
		case subscriptionSave = "subscription_save"
		case subscriptionDelete = "subscription_delete"
		case tap
		case view
		case turnOn = "turn_on"
		case turnOff = "turn_off"
		case update

		var name: String {
			return rawValue
		}
	}

	// MARK: - Environment
	enum Environment: String, EventTrackable {
		case unknown

		case prod
		case stage
		case dev

		var name: String {
			return rawValue
		}
	}

	// MARK: - Label
	enum Label: EventTrackable {
		case undefined
		case defined(String)

		var name: String {
			return self.rawValue
		}
	}

	// MARK: - Details
	enum Details: EventTrackable {
		case defined([EventDetailsParameter])

		var values: [EventDetailsParameter] {
			switch self {
			case .defined(let parameters):
				return parameters
			}
		}
		var name: String {
			switch self {
			case .defined:
				return "defined"
			}
		}
	}
}

extension Event.Label: RawRepresentable {

  public typealias RawValue = String

  /// Initalizer
  public init?(rawValue: RawValue) {
    switch rawValue {
    case "undefined":
      self = .undefined
    default:
      self = .defined(rawValue)
    }
  }

  /// Backing raw value
  public var rawValue: RawValue {
    switch self {
    case .undefined:
      return "undefined"
    case .defined(let label):
      return label
    }
  }
}
