//
//  EventAdvertisementFactory.swift
//  Lalafo
//
//  Created by Anton Ivashyna on 07/09/2017.
//  Copyright © 2017 Yallaclassified. All rights reserved.
//

import Foundation

typealias AdvertisementId = Int

protocol EventAdvertisementProtocol {
	var parametersAdvertisementId: AdvertisementId? { get }
	var parametersCategoryId: CategoryId? { get }
	var parametersCityId: Int? { get }
}

// MARK: - Advertisement: EventAdvertisementProtocol
extension Advertisement: EventAdvertisementProtocol {
	var parametersAdvertisementId: AdvertisementId? {
		return id
	}
	var parametersCategoryId: CategoryId? {
		return categoryId
	}
	var parametersCityId: Int? {
		return cityId
	}
}

// MARK: - ChatAdvertisement: EventAdvertisementProtocol
extension ChatAdvertisement: EventAdvertisementProtocol {
	var parametersAdvertisementId: AdvertisementId? {
		return id
	}
	var parametersCategoryId: CategoryId? {
		return categoryId
	}
	var parametersCityId: Int? {
		return nil
	}
}

// MARK: - ChatAdvertisement: EventAdvertisementProtocol
extension PostingAdvertisement: EventAdvertisementProtocol {
  var parametersAdvertisementId: AdvertisementId? {
    return id
  }
  var parametersCategoryId: CategoryId? {
    return category.value?.id
  }
  var parametersCityId: Int? {
    return nil
  }
}


// MARK: - MyShipment.Advertisement: EventAdvertisementProtocol
extension MyShipment.Advertisement: EventAdvertisementProtocol {
  var parametersAdvertisementId: AdvertisementId? {
    return id
  }
  var parametersCategoryId: CategoryId? {
    return nil
  }
  var parametersCityId: Int? {
    return nil
  }
}
