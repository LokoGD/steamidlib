# This test suite was poorly thrown together at 1AM in an effort to make sure
# everything was Okay(TM). Please do not look at it.

require 'minitest/spec'
require 'minitest/autorun'
require 'steamidlib'
# require_relative '../lib/steamidlib/steamidlib'
include SteamIDs


# Correct answers
steamid64 = '76561197960268402'
steamid64_url = 'https://steamcommunity.com/profiles/76561197960268402'
steamid32_url = 'https://steamcommunity.com/profiles/[U:1:2674]'
group_steamid64 = '103582795724488708'
group_steamid64_url = 'https://steamcommunity.com/gid/103582795724488708'
group_steamid32_url = 'https://steamcommunity.com/gid/[g:1:4]'

describe SteamID do
  it 'can convert to steamID64' do
    SteamID.new(0, 0, 1337).to_steamID64.to_s.must_equal steamid64
  end

  it 'can parse steamIDs' do
    SteamID.parse('STEAM_0:0:1337').to_steamID64.to_s.must_equal steamid64
  end

  it 'can generate steamID64 urls' do
    SteamID.new(0, 0, 1337).url.must_equal steamid64_url
    SteamID.parse('STEAM_0:0:1337').url.must_equal steamid64_url
  end
end

describe SteamID32 do
  it 'can convert to steamID64' do
    SteamID32.new(1, 0, 1337).to_steamID64.to_s.must_equal steamid64
  end

  it 'can parse steamID32s' do
    SteamID32.parse('[U:1:2674]').to_steamID64.to_s.must_equal steamid64
  end
  
  it 'can generate steamID32 urls' do
    SteamID32.new(1, 0, 1337).url.must_equal steamid32_url
    SteamID32.parse('[U:1:2674]').url.must_equal steamid32_url
  end

  it 'can parse group steamID32s' do
    SteamID32.parse('[g:1:4]').to_steamID64.to_s.must_equal group_steamid64
  end

  it 'can convert group steamID32 to steamID64' do
    SteamID32.new(7, 2, 1).to_steamID64.to_s.must_equal group_steamid64
  end

  it 'can generate group steamID32 urls' do
    SteamID32.parse('[g:1:4]').url.must_equal group_steamid32_url
    SteamID32.new(7, 2, 1).url.must_equal group_steamid32_url
  end
end

describe SteamID64 do
  it 'can parse steamID64' do
    SteamID64.parse('76561197960268402').to_s.must_equal steamid64
  end

  it 'can generate steamID64 urls' do
    SteamID64.parse('76561197960268402').url.must_equal steamid64_url
  end
  
  it 'can parse group steamID64s' do
    SteamID64.parse('103582795724488708').to_s.must_equal group_steamid64
    SteamID64.new(1, 7, 1, 4).to_s.must_equal group_steamid64
  end
  
  it 'can generate group steamID64 urls' do
    SteamID64.parse('103582795724488708').url.must_equal group_steamid64_url
    SteamID64.new(1, 7, 1, 4).url.must_equal group_steamid64_url
  end
end

describe SteamIDs do
  it 'has the correct steamID64 identifier headers' do
    STEAMACC_TYPES[1].steamID64_ident.must_equal 0x0110000100000000
    STEAMACC_TYPES[7].steamID64_ident.must_equal 0x0170000000000000
  end
end
