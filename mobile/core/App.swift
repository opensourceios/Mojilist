//
//  App.swift
//  Emojilist
//
//  Created by Thiago Ricieri on 04/01/18.
//  Copyright © 2018 GhostShip. All rights reserved.
//

import Foundation
import DateToolsSwift
import RealmSwift

protocol App {
	
	var config: AppConfig { get }
	var documentPath: String { get }
    var realm: Realm { get }
    var theme: Theme { get set }
	
	var humamFormatter: DateFormatter { get }
	var posixFormatter: DateFormatter { get }
    var sqlFormatter: DateFormatter { get }
	var currencyFormatter: NumberFormatter { get }
    
    func convertToDate(fromSql: String) -> Date?
    func convertToDate(fromSimpleSql: String) -> Date?
    func dateToSql(fromHuman: String) -> String
    func dateToSimpleSql(fromHuman: String) -> String
    func dateToHuman(fromSql: String) -> String
    func dateToHuman(from: String, toFormat: String) -> String
    func dateToHuman(fromSimpleSql: String) -> String
    
    func changeVisuals(_ visuals: Visuals)
    func standardEmojiPack() -> EmojiPackViewModel
}

// MARK: - Production App
class ProductionAppImpl: App {
	
    lazy var theme: Theme = self.initTheme()
    
	fileprivate(set) var config: AppConfig
	fileprivate(set) public var documentPath: String
    
    fileprivate(set) lazy var realm: Realm = self.initRealm()
	fileprivate(set) lazy var humamFormatter: DateFormatter = self.initHumanFormatter()
	fileprivate(set) lazy var posixFormatter: DateFormatter = self.initPosixFormatter()
    fileprivate(set) lazy var sqlFormatter: DateFormatter = self.initSqlFormatter()
    fileprivate(set) lazy var simpleSqlFormatter: DateFormatter = self.initSimpleSqlFormatter()
	fileprivate(set) lazy var currencyFormatter: NumberFormatter = self.initCurrencyFormatter()
	
	init() {
		self.config = ProductionAppConfigImpl()
		self.documentPath = ""
	}
    
    fileprivate func initRealm() -> Realm {
        return try! Realm()
    }
    
    fileprivate func initTheme() -> Theme {
        let defaults = UserDefaults.standard
        if let theme = defaults.string(forKey: Env.App.theming) {
            return Theme(visualString: theme)
        }
        return Theme(visuals: BasicVisual())
    }
	
	// Init formatters
	fileprivate func initHumanFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
	}
    
	fileprivate func initPosixFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd'T'HHmmssZZZ"
        df.locale = Locale(identifier:"en_US_POSIX")
        return df
	}
    
	fileprivate func initSqlFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
	}
    
    fileprivate func initSimpleSqlFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
    
	fileprivate func initCurrencyFormatter() -> NumberFormatter {
		let df = NumberFormatter()
		df.numberStyle = .currency
		df.locale = Locale(identifier: "pt_BR")
		return df
	}
    
    func dateToSql(fromHuman: String) -> String {
        let date = humamFormatter.date(from: fromHuman)
        return sqlFormatter.string(from: date!)
    }
    
    func dateToSimpleSql(fromHuman: String) -> String {
        let date = humamFormatter.date(from: fromHuman)
        return simpleSqlFormatter.string(from: date!)
    }
    
    func dateToHuman(fromSql: String) -> String {
        let date = sqlFormatter.date(from: fromSql)
        return humamFormatter.string(from: date!)
    }
    
    func convertToDate(fromSql: String) -> Date? {
        return sqlFormatter.date(from: fromSql)
    }
    
    func dateToHuman(fromSimpleSql: String) -> String {
        let date = simpleSqlFormatter.date(from: fromSimpleSql)
        return humamFormatter.string(from: date!)
    }
    
    func dateToHuman(from: String, toFormat: String) -> String {
        let df = DateFormatter()
        df.dateFormat = toFormat
        if let date = sqlFormatter.date(from: from) {
            return df.string(from: date)
        }
        return ""
    }
    
    func convertToDate(fromSimpleSql: String) -> Date? {
        return simpleSqlFormatter.date(from: fromSimpleSql)
    }
    
    // MARK: - Others
    
    func changeVisuals(_ visuals: Visuals) {
        theme.visuals = visuals
        let defaults = UserDefaults.standard
        defaults.set(visuals.identifier, forKey: Env.App.theming)
        
        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(visuals.icon)
        }
    }
    
    func standardEmojiPack() -> EmojiPackViewModel {
        let pack = realm.objects(REmojiPack.self).filter("ascii = true").first!
        return EmojiPackViewModel(with: pack)
    }
}

// MARK: - Staging App
class StagingAppImpl: ProductionAppImpl {
	
	public override init() {
		super.init()
		self.config = StagingAppConfigImpl()
	}
}
