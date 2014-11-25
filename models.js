

exports.sequelize = function(sequelize, DataTypes) {

  return {

    User: sequelize.define('User', {
      name: DataTypes.STRING,
      email: DataTypes.STRING,
      passwd: DataTypes.STRING,
      state: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 }
    })

  };

};
