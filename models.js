

exports.sequelize = function(sequelize, DataTypes) {

  return {

    User: sequelize.define('users', {
      name: DataTypes.STRING,
      email: DataTypes.STRING,
      passwd: DataTypes.STRING,
      state: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 }
    })

  };

};
