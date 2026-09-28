//
//  ContactEditorVMTests.swift
//  Version2Tests
//

import Core
import SwiftData
import XCTest
@testable import Version2

@MainActor
final class ContactEditorVMTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repo: StoreRepository!
    private var vm: ContactEditorVM!

    override func setUpWithError() throws {
        container = try TestContainers.v2()
        context = ModelContext(container)
        context.autosaveEnabled = false
        repo = StoreRepository(context: context)
        vm = ContactEditorVM(storeRepo: repo)
    }

    func testNavTitle_newContact_usesNewContactCopy() {
        XCTAssertEqual(vm.navTitle(isNewContact: true), "New Contact")
        XCTAssertEqual(vm.navTitle(isNewContact: false), "")
    }

    func testSave_newContact_persistsAndSetsFinishAction() throws {
        let dto = ContactDTO(
            firstName: "Ada",
            lastName: "Lovelace",
            phoneNumbers: [.init(tag: .mobile, number: "555-0100", isPrimary: true)]
        )

        vm.save(dto, isNewContact: true)

        XCTAssertEqual(vm.finishAction, .saved)
        XCTAssertNil(vm.editAlert)

        let fetched = try context.fetch(FetchDescriptor<Contact>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.firstName, "Ada")
        XCTAssertEqual(fetched.first?.phoneNumbers?.first?.number, "555-0100")
    }

    func testSave_existingContact_updatesAndSetsFinishAction() throws {
        let created = repo.createContact(from: ContactDTO(
            firstName: "Ada",
            phoneNumbers: [.init(tag: .mobile, number: "111", isPrimary: true)]
        ))
        try repo.save()

        let update = ContactDTO(
            stableId: created.stableId,
            firstName: "Augusta",
            lastName: "King",
            phoneNumbers: [.init(tag: .mobile, number: "222", isPrimary: true)]
        )
        vm.save(update, isNewContact: false)

        XCTAssertEqual(vm.finishAction, .saved)
        XCTAssertNil(vm.editAlert)

        let fetched = try XCTUnwrap(repo.fetchContact(stableId: created.stableId))
        XCTAssertEqual(fetched.firstName, "Augusta")
        XCTAssertEqual(fetched.lastName, "King")
        XCTAssertEqual(fetched.phoneNumbers?.first?.number, "222")
    }

    func testSave_existingContactMissing_setsSaveFailureAlert() {
        let dto = ContactDTO(stableId: "missing-id", firstName: "Ghost")

        vm.save(dto, isNewContact: false)

        XCTAssertNil(vm.finishAction)
        guard case .saveFailure(let failedDTO, let isNew)? = vm.editAlert else {
            return XCTFail("Expected saveFailure alert, got \(String(describing: vm.editAlert))")
        }
        XCTAssertEqual(failedDTO.stableId, "missing-id")
        XCTAssertFalse(isNew)
    }

    func testSave_whenRepairBehind_setsSaveFailureAlert() throws {
        let contact = Contact(repairVersion: 1, firstName: "Behind")
        context.insert(contact)
        try repo.save()

        let dto = ContactDTO(stableId: contact.stableId, repairVersion: 1, firstName: "Still Behind")
        vm.save(dto, isNewContact: false)

        XCTAssertNil(vm.finishAction)
        guard case .saveFailure(_, let isNew)? = vm.editAlert else {
            return XCTFail("Expected saveFailure alert, got \(String(describing: vm.editAlert))")
        }
        XCTAssertFalse(isNew)
    }

    func testDelete_existingContact_removesAndSetsFinishAction() throws {
        let created = repo.createContact(from: ContactDTO(firstName: "Temp"))
        try repo.save()

        vm.delete(ContactDTO(stableId: created.stableId))

        XCTAssertEqual(vm.finishAction, .deleted)
        XCTAssertNil(vm.editAlert)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Contact>()).isEmpty)
    }

    func testDelete_missingContact_setsDeleteFailureAlert() {
        let dto = ContactDTO(stableId: "missing-id", firstName: "Ghost")

        vm.delete(dto)

        XCTAssertNil(vm.finishAction)
        guard case .deleteFailure(let failedDTO) = vm.editAlert else {
            return XCTFail("Expected deleteFailure alert, got \(String(describing: vm.editAlert))")
        }
        XCTAssertEqual(failedDTO.stableId, "missing-id")
    }

    func testTryAgain_fromSaveFailure_retriesAndSucceedsAfterCreate() throws {
        let dto = ContactDTO(firstName: "Retry", phoneNumbers: [.init(tag: .mobile, number: "555")])

        vm.editAlert = .saveFailure(dto, isNewContact: true)
        vm.tryAgain(.saveFailure(dto, isNewContact: true))

        XCTAssertEqual(vm.finishAction, .saved)
        XCTAssertNil(vm.editAlert)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Contact>()).count, 1)
    }

    func testTryAgain_fromDeleteFailure_retriesAndSucceeds() throws {
        let created = repo.createContact(from: ContactDTO(firstName: "RetryDelete"))
        try repo.save()
        let dto = ContactDTO(stableId: created.stableId)

        vm.editAlert = .deleteFailure(dto)
        vm.tryAgain(.deleteFailure(dto))

        XCTAssertEqual(vm.finishAction, .deleted)
        XCTAssertNil(vm.editAlert)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Contact>()).isEmpty)
    }
}
