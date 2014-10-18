# Based on these:
# https://developer.valvesoftware.com/wiki/SteamID
# http://steamidconverter.com
# https://gist.github.com/KBlair/4eae86ae1d10364bb66d
# http://www.steam-utilities.net/show-database-steamid.html
# Steam API

# How the hell do I use this?
# Reading this (https://developer.valvesoftware.com/wiki/SteamID) will help.
#
# SteamID format: STEAM_X:Y:Z
# How to call SteamID.new:   SteamID.new(X, Y, Z)
# Of course, the digits aren't actually going to be X, Y, and Z.
# X, Y, and Z should be numbers. If you need to parse a SteamID string, use
# SteamID.parse().
#
# SteamID32 format: [L:1:W]
# L is the letter for the type of account the SteamID represents.
# W is 2Z + Y.
# Use SteamID32.new(type, Y, Z). The types of steam accounts are listed at the
# article linked above. The type should be the number of which type it is (for
# example, for an account with an 'Individual' type, 1 should be the value of
# type.
#
# SteamID64 format: a 64 bit struct
# Most accounts have a universe of 0 or 1 (it doesn't really matter), a
# type of 1, an instance of 1, and the accountID64 is just W.
# Honestly, I would just use SteamID64.parse().

module SteamIDs
  # Datavalues and stuff to avoid magic numbers later on
  SteamAccType = Struct.new(:number, :letter, :type, :usable,
                            :path, :steamID64_ident)
  STEAMACC_TYPES =
  [
    SteamAccType.new(0, 'I', 'Invalid', false, nil, 0x0),
    SteamAccType.new(1, 'U', 'Individual', true, 'profiles', 0x01100001 << 32),
    SteamAccType.new(2, 'M', 'Multiseat', true, nil, 0x0),
    SteamAccType.new(3, 'G', 'GameServer', true, nil, 0x0),
    SteamAccType.new(4, 'A', 'AnonGameServer', true, nil, 0x0),
    SteamAccType.new(5, 'P', 'Pending', false, nil, 0x0),
    SteamAccType.new(6, 'C', 'ContentServer', false, nil, 0x0),
    SteamAccType.new(7, 'g', 'Clan', true, 'gid', 0x017 << 52),
    SteamAccType.new(8, ['c', 'L', 'T'], 'Chat', true, nil, 0x0),
    SteamAccType.new(9, nil, 'P2P SuperSeeder', false, nil, 0x0),
    SteamAccType.new(10, nil, 'AnonUser', false, nil, 0x0)
  ]
  STEAMACC_UNIVERSES =
  [
    'Individual/Unspecified',
    'Public',
    'Beta',
    'Internal',
    'Dev',
    'RC'
  ]

  # A SteamID. Looks like STEAM_0:0:12345. As far as I know, it can only
  # represent players.
  SteamID = Struct.new(:universe, :id, :accountID) do
    # The string representation of this SteamID. Looks like STEAM_0:0:1337.
    def to_s
      "STEAM_#{universe}:#{id}:#{accountID}"
    end

    # The URL on steamcommunity.com for this SteamID.
    def url
      to_steamID64.url
    end

    # Returns the SteamID32 representation of this SteamID.
    def to_steamID32
      return SteamID64.new(type, id, accountID)
    end

    # Returns the SteamID64 representation of this SteamID.
    def to_steamID64
      # overwrite 1 as universe for reasons
      return SteamID64.new(1, 1, 1, accountID * 2 + id)
    end

    # Returns a SteamID that represents the string steamID passed. It does not
    # perform any sort of validation!
    def self.parse(steamID)
      parts = steamID.split ':'
      universe = parts[0][-1].to_i
      type = parts[1].to_i
      accountID = parts[2].to_i
      SteamID.new(universe, type, accountID)
    end
  end

  # A SteamID32. It's the 32-bit version of SteamID64. Looks like [U:1:12345].
  # As far as I know, it can represent any sort of account.
  SteamID32 = Struct.new(:type, :id, :accountID) do
    # The numberical representation of this SteamID32. It's the third number
    # in the string representation. This is *not* the actual accountID, it
    # actually factors in both the real accountID and auth server id and packs
    # them together.
    def to_i
      2 * accountID + id
    end

    # The string representation of this SteamID32. It looks like [U:1:12345].
    def to_s
      "[#{STEAMACC_TYPES[type].letter}:1:#{to_i}]"
    end

    # The URL on steamcommunity.com for this SteamID32.
    def url
      path = STEAMACC_TYPES[type].path
      return nil if path.nil?
      return "https://steamcommunity.com/#{path}/#{to_s}"
    end

    # Returns a SteamID representation of this SteamID32.
    def to_steamID
      SteamID.new(type, id, accountID)
    end

    # Returns a SteamID64 representation of this SteamID32.
    def to_steamID64
      return SteamID64.new(1, type, 1, to_i)
    end

    # Returns a SteamID32 that represents the string steamID32 passed. It does
    # not perform any sort of validation!
    def self.parse(steamID32)
      parts = steamID32[1..-2].split(':')
      type = nil
      STEAMACC_TYPES.each do |acc_type|
        type = acc_type.number if acc_type.letter == parts[0]
      end
      accountID = parts[2].to_i
      id = accountID % 2
      accountID >>= 1
      SteamID32.new(type, id, accountID)
    end
  end

  # A SteamID64. It's the 64-bit version of SteamID32. It's also known as the
  # friend ID or community ID. It looks like 76561197960268402.
  # As far as I know, it can represent any sort of account.
  # Please note that accountID64 is the same as SteamID32.to_i(). It's not
  # actually the real accountID. It's snake oil.
  SteamID64 = Struct.new(:universe, :type, :instance, :accountID64) do
    # The numerical representation of this SteamID64. It's what you're used to
    # seeing.
    def to_i
      accountID64 | (instance << 32) | (type << 52) | (universe << 56)
    end

    # The string representation of this SteamID64, which is just a thin veil
    # ontop of the numerical representation, but has a few special checks first
    # to conform to the specification at
    # https://developer.valvesoftware.com/wiki/SteamID. See the bottom of the
    # section 'Types of Steam Accounts', under the table for more detailed
    # information on special cases with SteamIDs.
    def to_s
      if type == 5
        return 'STEAM_ID_PENDING'
      elsif type == 0
        return 'UNKNOWN'
      else
        return to_i.to_s
      end
    end

    # Returns the URL on steamcommunity.com for this SteamID64.
    def url
      path = STEAMACC_TYPES[type].path
      return nil if path.nil?
      return "https://steamcommunity.com/#{path}/#{to_i}"
    end

    # Returns the *actual* accountID for this SteamID64. accountID64 is
    # actually snake oil trickery. It's also the same as SteamID32.to_i().
    def accountID
      accountID64 >> 1
    end

    # The id of this SteamID64, that would be used for other SteamID formats.
    def id
      accountID64 % 2
    end

    # Returns a SteamID representation of this SteamID64.
    def to_steamID
      SteamID.new(type, id, accountID)
    end

    # Returns a SteamID32 representation of this SteamID64.
    def to_steamID32
      SteamID32.new(type, id, accountID)
    end

    # Returns a SteamID64 that represents the string steamID64 passed. It does
    # not perform any sort of validation! Uses hacky bitmasks and shifts to
    # get the SteamID64 identifier header bits.
    def self.parse(steamID64)
      steamID64 = steamID64.to_i
      accountID64 = (steamID64 & 0b11111111111111111111111111111111)
      instance = (steamID64 & (0b11111111111111111111 << 32)) >> 32
      type = (steamID64 & (0b1111 << 52)) >> 52
      universe = (steamID64 & (0b11111111 << 56)) >> 56
      SteamID64.new(universe, type, instance, accountID64)
    end
  end
end
