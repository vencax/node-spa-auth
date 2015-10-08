
module.exports = (sequelize, DataTypes) ->

  User = sequelize.define 'user',
    uname:
      type: DataTypes.STRING
      allowNull: false
      unique: true
    name: DataTypes.STRING
    email: DataTypes.STRING
    passwd: DataTypes.STRING
    state:
      type: DataTypes.INTEGER
      allowNull: false
      defaultValue: 0
  ,
    tableName: "users"


  Group = sequelize.define "group",
    name:
      type: DataTypes.STRING
      allowNull: false
      unique: true
  ,
    tableName: "groups"


  User.belongsToMany Group,
    as: 'groups'
    through: 'usergroup'
    foreignKey: 'userId'

  Group.belongsToMany User,
    as: 'users'
    through: 'usergroup'
    foreignKey: 'groupId'
