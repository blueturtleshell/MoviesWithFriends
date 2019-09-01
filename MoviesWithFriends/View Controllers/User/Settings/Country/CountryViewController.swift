//
//  RegionViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/28/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol CountryViewControllerDelegate: AnyObject {
    func didSelectNewCountry(viewController: CountryViewController, country: Country)
}

class CountryViewController: UITableViewController {

    private var countries = [Country]()

    private lazy var firstLetter: [String] = {
        return Array(Set(countries.map({ country -> String in
            return String(country.name.uppercased().first!)
        }))).sorted()
    }()

    private lazy var countriesSortedByInitial: [String: [Country]] = {
        var dict = [String: [Country]]()
        for letter in firstLetter {
            var countryThatFit = [Country]()
            for country in countries {
                if String(country.name.uppercased().first!) == letter {
                    countryThatFit.append(country)
                }
            }
            dict[letter] = countryThatFit
        }
        return dict
    }()

    weak var delegate: CountryViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        getCountries()
    }

    private func setupView() {
        tableView.register(CountryCell.self, forCellReuseIdentifier: "CountryCell")
        tableView.backgroundView = BlurBackgroundView()
        tableView.sectionIndexColor = UIColor(named: "offYellow")
    }

    private func getCountries() {
        if let url = Bundle.main.url(forResource: "country", withExtension: "json") {
            do {
                let jsonDecoder = JSONDecoder()
                let data = try Data(contentsOf: url)
                countries = try jsonDecoder.decode([Country].self, from: data)
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return firstLetter.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return firstLetter[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.reduce(0) { result, country -> Int in
            return result + ((String(country.name.uppercased().first!) == self.firstLetter[section]) ? 1 : 0)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryCell

        let regions = countriesSortedByInitial[firstLetter[indexPath.section]]!.sorted { $0.name < $1.name }

        cell.textLabel?.text = regions[indexPath.row].name
        let currentCountryName = UserDefaults.standard.string(forKey: "countryName")
        cell.accessoryType = regions[indexPath.row].name == currentCountryName ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countriesSorted = countriesSortedByInitial[firstLetter[indexPath.section]]!.sorted { $0.name < $1.name }
        let selectedCountry = countriesSorted[indexPath.row]

        delegate?.didSelectNewCountry(viewController: self, country: selectedCountry)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(Set(countries.map({ country -> String in
            return String(country.name.uppercased().first!)
        }))).sorted()
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return firstLetter.firstIndex(of: title)!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
