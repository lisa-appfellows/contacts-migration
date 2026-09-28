//
//  ContactEditorVMTests.swift
//  Version1Tests
//

import Core
import SwiftData
import XCTest
@testable import Version1

@MainActor
final class ContactEditorVMTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repo: StoreRepository!
    private var vm: ContactEditorVM!

    override func setUpWithError() throws {
        container = try TestContainers.v1()
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
            phoneNumber: "555-0100"
        )

        vm.save(dto, isNewContact: true)

        XCTAssertEqual(vm.finishAction, .saved)
        XCTAssertNil(vm.editAlert)

        let fetched = try context.fetch(FetchDescriptor<Contact>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.firstName, "Ada")
        XCTAssertEqual(fetched.first?.phoneNumber, "555-0100")
    }

    func testSave_existingContact_updatesAndSetsFinishAction() throws {
        let created = repo.createContact(from: ContactDTO(firstName: "Ada", phoneNumber: "111"))
        try repo.save()

        let update = ContactDTO(
            stableId: created.stableId,
            firstName: "Augusta",
            lastName: "King",
            phoneNumber: "222"
        )
        vm.save(update, isNewContact: false)

        XCTAssertEqual(vm.finishAction, .saved)
        XCTAssertNil(vm.editAlert)

        let fetched = try XCTUnwrap(repo.fetchContact(stableId: created.stableId))
        XCTAssertEqual(fetched.firstName, "Augusta")
        XCTAssertEqual(fetched.lastName, "King")
        XCTAssertEqual(fetched.phoneNumber, "222")
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
        let dto = ContactDTO(firstName: "Retry", phoneNumber: "555")

        // Force a save-failure alert shape, then retry as new contact create.
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
