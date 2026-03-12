// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      isGuest: json['isGuest'] as bool? ?? false,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      zip: json['zip'] as String?,
      zone: json['zone'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'isGuest': instance.isGuest,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'zip': instance.zip,
      'zone': instance.zone,
      'location': instance.location,
    };
