import 'dart:convert';

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'contacts.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // Create tables for Contact and its related classes
      await db.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY,
          display_name TEXT NOT NULL,
          photo BLOB,
          thumbnail BLOB,
          name INTEGER,
          phonelist TEXT,
          emaillist TEXT,
          addrlist TEXT,
          orglist TEXT,
          weblist TEXT,
          smedialist TEXT,
          eventlist TEXT,
          notelist TEXT,
          grplist TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE name (
          id INTEGER PRIMARY KEY,
          first TEXT NOT NULL,
          last TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE phones (
          phid INTEGER PRIMARY KEY,
          id INTEGER,
          number TEXT,
          label TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE emails (
          emailid INTEGER PRIMARY KEY, 
          id INTEGER,
          address TEXT,
          label TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE addresses (
          addrid INTEGER PRIMARY KEY,
          id INTEGER,
          address TEXT,
          label TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');


      await db.execute('''
        CREATE TABLE organizations (
          orgid INTEGER PRIMARY KEY, 
          id INTEGER,
          company TEXT,
          title TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');


      await db.execute('''
        CREATE TABLE websites (
          webid INTEGER PRIMARY KEY, 
          id INTEGER,
          url TEXT,
          label TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');


      await db.execute('''
        CREATE TABLE socialmedia (
          smid INTEGER PRIMARY KEY, 
          id INTEGER,
          username TEXT,
          label TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE events (
          eventid INTEGER PRIMARY KEY, 
          id INTEGER ,
          year INTEGER,
          month INTEGER,
          day INTEGER,
          label TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE notes (
          noteid INTEGER PRIMARY KEY,
          id INTEGER, 
          note TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE groups (
          grpid INTEGER PRIMARY KEY,
          id INTEGER,
          gid TEXT,
          name TEXT,
          FOREIGN KEY(id) REFERENCES contacts(id)
        )
      ''');
    });
  }

  Future<void> putContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', {
      'id':contact.id,
      'display_name': contact.displayName,
      'photo': contact.photo,
      'thumbnail': contact.thumbnail,
      'name':contact.id
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  List<int> decodeIdList(String jsonEncodedData) {
    final List<dynamic> decodedList = jsonDecode(jsonEncodedData);
    return decodedList.map((id) => int.parse(id.toString())).toList();
  }
  Future<Contact?> getContact(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> contactData = maps[0];

    final String phoneListJson = contactData['phonelist'];

    final List<int> phoneIds = decodeIdList(phoneListJson);

    final List<Phone> phones = [];

    for (int phoneId in phoneIds) {
      final List<Map<String, dynamic>> phoneData = await db.query('phones',
          where: 'phid = ?',
          whereArgs: [phoneId]);

      if (phoneData.isNotEmpty) {
        final Map<String, dynamic> phoneMap = phoneData.first;
        final Phone phone = Phone(
          phoneMap['number'],
          label: phoneMap['label'],
        );
        phones.add(phone);
      }
    }

    final String emailListJson = contactData['emaillist'];

    final List<int> emailIds = decodeIdList(emailListJson);

    final List<Email> emails = [];

    for (int emailId in emailIds) {
      final List<Map<String, dynamic>> emailData = await db.query('emails',
          where: 'emailid = ?',
          whereArgs: [emailId]);

      if (emailData.isNotEmpty) {
        final Map<String, dynamic> emailMap = emailData.first;
        final Email email = Email(
          emailMap['address'],
          label: emailMap['label'],
        );
        emails.add(email);
      }
    }

    final String addressListJson = contactData['addrlist'];

    final List<int> addressIds = decodeIdList(addressListJson);

    final List<Address> addresses = [];

    for (int addressId in addressIds) {
      final List<Map<String, dynamic>> addressData = await db.query('addresses',
          where: 'addrid = ?',
          whereArgs: [addressId]);

      if (addressData.isNotEmpty) {
        final Map<String, dynamic> addressMap = addressData.first;
        final Address address = Address(
          addressMap['address'],
          label: addressMap['label'],
        );
        addresses.add(address);
      }
    }


    final String organizationListJson = contactData['orglist'];

    final List<int> organizationIds = decodeIdList(organizationListJson);

    final List<Organization> organizations = [];

    for (int organizationId in organizationIds) {
      final List<Map<String, dynamic>> organizationData = await db.query('organizations',
          where: 'orgid = ?',
          whereArgs: [organizationId]);

      if (organizationData.isNotEmpty) {
        final Map<String, dynamic> organizationMap = organizationData.first;
        final Organization organization = Organization(
          company: organizationMap['company'],
          title: organizationMap['title'],
        );
        organizations.add(organization);
      }
    }


    final String webListJson = contactData['weblist'];

    final List<int> webIds = decodeIdList(webListJson);

    final List<Website> websites = [];

    for (int webId in webIds) {
      final List<Map<String, dynamic>> webData = await db.query('websites',
          where: 'webid = ?',
          whereArgs: [webId]);

      if (webData.isNotEmpty) {
        final Map<String, dynamic> webMap = webData.first;
        final Website website = Website(
          webMap['url'],
          label: webMap['label'],
        );
        websites.add(website);
      }
    }


    final String smedialistJson = contactData['smedialist'];

    final List<int> smediaIds = decodeIdList(smedialistJson);

    final List<SocialMedia> socialMedias = [];

    for (int smediaId in smediaIds) {
      final List<Map<String, dynamic>> smediaData = await db.query('socialmedia',
          where: 'smid = ?',
          whereArgs: [smediaId]);

      if (smediaData.isNotEmpty) {
        final Map<String, dynamic> smediaMap = smediaData.first;
        final SocialMedia smedia = SocialMedia(
          smediaMap['username'],
          label: smediaMap['label'],
        );
        socialMedias.add(smedia);
      }
    }



    final String eventListJson = contactData['eventlist'];

    final List<int> eventIds = decodeIdList(eventListJson);

    final List<Event> events = [];

    for (int eventId in eventIds) {
      final List<Map<String, dynamic>> eventData = await db.query('events',
          where: 'eventid = ?',
          whereArgs: [eventId]);

      if (eventData.isNotEmpty) {
        final Map<String, dynamic> eventMap = eventData.first;
        final Event event = Event(
          year: eventMap['year'],
          month: eventMap['month'],
          day: eventMap['day'],
          label: eventMap['label'],
        );
        events.add(event);
      }
    }


    final String notelistJson = contactData['notelist'];

    final List<int> noteIds = decodeIdList(notelistJson);

    final List<Note> notes = [];

    for (int noteId in noteIds) {
      final List<Map<String, dynamic>> noteData = await db.query('notes',
          where: 'noteid = ?',
          whereArgs: [noteId]);

      if (noteData.isNotEmpty) {
        final Map<String, dynamic> noteMap = noteData.first;
        final Note note = Note(
          noteMap['note'],
        );
        notes.add(note);
      }
    }


    final String groupListJson = contactData['grplist'];

    final List<int> groupIds = decodeIdList(groupListJson);

    final List<Group> groups = [];

    for (int groupId in groupIds) {
      final List<Map<String, dynamic>> groupData = await db.query('groups',
          where: 'grpid = ?',
          whereArgs: [groupId]);

      if (groupData.isNotEmpty) {
        final Map<String, dynamic> groupMap = groupData.first;
        final Group group = Group(
          groupMap['gid'],
          groupMap['name'],
        );
        groups.add(group);
      }
    }

    final Name? contactName = await fetchNameForContact(contactData['id']);


    return Contact(
      id: maps[0]['id'],
      displayName: maps[0]['display_name'],
      photo: maps[0]['photo'],
      thumbnail: maps[0]['thumbnail'],
      name:contactName,
      phones: phones,
      emails: emails,
      addresses: addresses,
      organizations: organizations,
      websites: websites,
      socialMedias: socialMedias,
      events: events,
      notes: notes,
      groups: groups,
    );
  }

//Function to fetch names
  Future<Name?> fetchNameForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> nameData = await db.query(
      'name',
      columns: ['first', 'last'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (nameData.isNotEmpty) {
      final Map<String, dynamic> nameMap = nameData.first;
      return Name(
        first: nameMap['first'],
        last: nameMap['last'],
      );
    }

    return null;
  }




  Future<void> putNames(Name name, int contactId) async {
    final db = await database;

    // Insert the name record
    await db.insert('name', {
      'id': contactId,
      'first': name.first,
      'last': name.last,
    });
  }

// insert ant update for phone....................................
  Future<void> putPhones(List<Phone> phones, int contactId) async {
    final db = await database;

    // Insert all phone records
    for (var phone in phones) {
      await db.insert('phones', {
        'id': contactId,
        'number': phone.number,
        'label': phone.label,
      });
    }

    // Get the list of phone IDs
    final phoneIds = await fetchPhoneIdsForContact(contactId);

    // Update the contacts table with the new phonelist
    await updatePhoneListForContact(contactId, phoneIds);
  }
  Future<List<int>> fetchPhoneIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> phoneMaps = await db.query(
      'phones',
      columns: ['phid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    return phoneMaps.map((phoneMap) => phoneMap['phid'] as int).toList();
  }

  Future<void> updatePhoneListForContact(int contactId, List<int> phoneIds) async {
    final db = await database;

    // Encode the list of phone IDs to JSON
    final phoneListJson = jsonEncode(phoneIds);

    // Update the contacts table with the new phonelist
    await db.update('contacts', {'phonelist': phoneListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }

// insert and update for emails................................................
  Future<void> putEmails(List<Email> emails, int contactId) async {
    final db = await database;

    // Insert all email records
    for (var email in emails) {
      await db.insert('emails', {
        'id': contactId,
        'address': email.address,
        'label': email.label,
      });
    }

    // Get the list of email IDs
    final emailIds = await fetchEmailIdsForContact(contactId);

    // Update the contacts table with the new emaillist
    await updateEmailListForContact(contactId, emailIds);
  }

  Future<List<int>?> fetchEmailIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> emailMaps = await db.query(
      'emails',
      columns: ['emailid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (emailMaps.isEmpty) {
      return null;
    }

    return emailMaps.map((emailMap) => emailMap['emailid'] as int).toList();
  }

  Future<void> updateEmailListForContact(int contactId, List<int>? emailIds) async {
    final db = await database;

    // Encode the list of email IDs to JSON
    final emailListJson = emailIds != null ? jsonEncode(emailIds) : null;

    // Update the contacts table with the new emaillist
    await db.update('contacts', {'emaillist': emailListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }


// insert and update for address................................................
  Future<void> putAddresses(List<Address> addresses, int contactId) async {
    final db = await database;

    // Insert all address records
    for (var address in addresses) {
      await db.insert('addresses', {
        'id': contactId,
        'address': address.address,
        'label': address.label,
      });
    }

    // Get the list of address IDs
    final addressIds = await fetchAddressIdsForContact(contactId);

    // Update the contacts table with the new addresslist
    await updateAddressListForContact(contactId, addressIds);
  }

  Future<List<int>?> fetchAddressIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> addressMaps = await db.query(
      'addresses',
      columns: ['addrid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (addressMaps.isEmpty) {
      return null;
    }

    return addressMaps.map((addressMap) => addressMap['addrid'] as int).toList();
  }

  Future<void> updateAddressListForContact(int contactId, List<int>? addressIds) async {
    final db = await database;

    // Encode the list of address IDs to JSON
    final addressListJson = addressIds != null ? jsonEncode(addressIds) : null;

    // Update the contacts table with the new addresslist
    await db.update('contacts', {'addrlist': addressListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }


// insert and update for organizations................................................
  Future<void> putOrganizations(List<Organization> organizations, int contactId) async {
    final db = await database;

    // Insert all organization records
    for (var organization in organizations) {
      await db.insert('organizations', {
        'id': contactId,
        'company': organization.company,
        'title': organization.title,
      });
    }

    // Get the list of organization IDs
    final organizationIds = await fetchOrganizationIdsForContact(contactId);

    // Update the contacts table with the new orglist
    await updateOrganizationListForContact(contactId, organizationIds);
  }

  Future<List<int>?> fetchOrganizationIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> organizationMaps = await db.query(
      'organizations',
      columns: ['orgid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (organizationMaps.isEmpty) {
      return null;
    }

    return organizationMaps.map((organizationMap) => organizationMap['orgid'] as int).toList();
  }

  Future<void> updateOrganizationListForContact(int contactId, List<int>? organizationIds) async {
    final db = await database;

    // Encode the list of organization IDs to JSON
    final organizationListJson = organizationIds != null ? jsonEncode(organizationIds) : null;

    // Update the contacts table with the new orglist
    await db.update('contacts', {'orglist': organizationListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }



// insert and update for websites................................................
  Future<void> putWebsites(List<Website> websites, int contactId) async {
    final db = await database;

    // Insert all website records
    for (var website in websites) {
      await db.insert('websites', {
        'id': contactId,
        'url': website.url,
        'label': website.label,
      });
    }

    // Get the list of website IDs
    final websiteIds = await fetchWebsiteIdsForContact(contactId);

    // Update the contacts table with the new weblist
    await updateWebsiteListForContact(contactId, websiteIds);
  }

  Future<List<int>?> fetchWebsiteIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> websiteMaps = await db.query(
      'websites',
      columns: ['webid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (websiteMaps.isEmpty) {
      return null;
    }

    return websiteMaps.map((websiteMap) => websiteMap['webid'] as int).toList();
  }

  Future<void> updateWebsiteListForContact(int contactId, List<int>? websiteIds) async {
    final db = await database;

    // Encode the list of website IDs to JSON
    final websiteListJson = websiteIds != null ? jsonEncode(websiteIds) : null;

    // Update the contacts table with the new weblist
    await db.update('contacts', {'weblist': websiteListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }


// insert and update for social media................................................
  Future<void> putSocialMedia(List<SocialMedia> socialMedias, int contactId) async {
    final db = await database;

    // Insert all social media records
    for (var socialMedia in socialMedias) {
      await db.insert('socialmedia', {
        'id': contactId,
        'username': socialMedia.userName,
        'label': socialMedia.label,
      });
    }

    // Get the list of social media IDs
    final socialMediaIds = await fetchSocialMediaIdsForContact(contactId);

    // Update the contacts table with the new smedialist
    await updateSocialMediaListForContact(contactId, socialMediaIds);
  }

  Future<List<int>?> fetchSocialMediaIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> socialMediaMaps = await db.query(
      'socialmedia',
      columns: ['smid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (socialMediaMaps.isEmpty) {
      return null;
    }

    return socialMediaMaps.map((socialMediaMap) => socialMediaMap['smid'] as int).toList();
  }

  Future<void> updateSocialMediaListForContact(int contactId, List<int>? socialMediaIds) async {
    final db = await database;

    // Encode the list of social media IDs to JSON
    final socialMediaListJson = socialMediaIds != null ? jsonEncode(socialMediaIds) : null;

    // Update the contacts table with the new smedialist
    await db.update('contacts', {'smedialist': socialMediaListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }


// insert and update for events................................................
  Future<void> putEvents(List<Event> events, int contactId) async {
    final db = await database;

    // Insert all event records
    for (var event in events) {
      await db.insert('events', {
        'id': contactId,
        'year': event.year,
        'month': event.month,
        'day': event.day,
        'label': event.label,
      });
    }

    // Get the list of event IDs
    final eventIds = await fetchEventIdsForContact(contactId);

    // Update the contacts table with the new eventlist
    await updateEventListForContact(contactId, eventIds);
  }

  Future<List<int>?> fetchEventIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> eventMaps = await db.query(
      'events',
      columns: ['eventid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (eventMaps.isEmpty) {
      return null;
    }

    return eventMaps.map((eventMap) => eventMap['eventid'] as int).toList();
  }

  Future<void> updateEventListForContact(int contactId, List<int>? eventIds) async {
    final db = await database;

    // Encode the list of event IDs to JSON
    final eventListJson = eventIds != null ? jsonEncode(eventIds) : null;

    // Update the contacts table with the new eventlist
    await db.update('contacts', {'eventlist': eventListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }


// insert and update for notes................................................
  Future<void> putNotes(List<Note> notes, int contactId) async {
    final db = await database;

    // Insert all note records
    for (var note in notes) {
      await db.insert('notes', {
        'id': contactId,
        'note': note.note,
      });
    }

    // Get the list of note IDs
    final noteIds = await fetchNoteIdsForContact(contactId);

    // Update the contacts table with the new notelist
    await updateNoteListForContact(contactId, noteIds);
  }

  Future<List<int>?> fetchNoteIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> noteMaps = await db.query(
      'notes',
      columns: ['noteid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (noteMaps.isEmpty) {
      return null;
    }

    return noteMaps.map((noteMap) => noteMap['noteid'] as int).toList();
  }

  Future<void> updateNoteListForContact(int contactId, List<int>? noteIds) async {
    final db = await database;

    // Encode the list of note IDs to JSON
    final noteListJson = noteIds != null ? jsonEncode(noteIds) : null;

    // Update the contacts table with the new notelist
    await db.update('contacts', {'notelist': noteListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }



  Future<void> putGroups(List<Group> groups, int contactId) async {
    final db = await database;

    // Insert all group records
    for (var group in groups) {
      await db.insert('groups', {
        'id': contactId,
        'gid': group.id,
        'name': group.name,
      });
    }

    // Get the list of group IDs
    final groupIds = await fetchGroupIdsForContact(contactId);

    // Update the contacts table with the new grplist
    await updateGroupListForContact(contactId, groupIds);
  }

  Future<List<int>?> fetchGroupIdsForContact(int contactId) async {
    final db = await database;

    final List<Map<String, dynamic>> groupMaps = await db.query(
      'groups',
      columns: ['grpid'],
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (groupMaps.isEmpty) {
      return null;
    }

    return groupMaps.map((groupMap) => groupMap['grpid'] as int).toList();
  }

  Future<void> updateGroupListForContact(int contactId, List<int>? groupIds) async {
    final db = await database;

    // Encode the list of group IDs to JSON
    final groupListJson = groupIds != null ? jsonEncode(groupIds) : null;

    // Update the contacts table with the new grplist
    await db.update('contacts', {'grplist': groupListJson},
        where: 'id = ?', whereArgs: [contactId]);
  }


}
