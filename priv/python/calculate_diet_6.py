from pulp import LpMinimize, LpProblem, LpStatus, lpSum, LpVariable, value
import json
import click

@click.command()
@click.argument('products_json', required=1)
@click.argument('diet_json', required=1)
@click.option('--lower_boundary', default=0.25, help='your minimum number of desired calories')
@click.option('--upper_boundary', default=3.5, help='your maximum number of desired calories')
@click.option('--enhance', default=5, help="macro elements enhance value")
def calculate_meal_6(products_json, diet_json, lower_boundary, upper_boundary, enhance):
  """Calculates meal with given 6 products."""
  products_dictionary = json.loads(products_json)
  diets_dictionary = json.loads(diet_json)

  model = LpProblem(name="diet-minimization", sense=LpMinimize)

  product_1_kcal = products_dictionary["product1"]["kcal"]
  product_1_proteins = products_dictionary["product1"]["proteins"]
  product_1_carbs = products_dictionary["product1"]["carbs"]
  product_1_fats = products_dictionary["product1"]["fats"]

  product_2_kcal = products_dictionary["product2"]["kcal"]
  product_2_proteins = products_dictionary["product2"]["proteins"]
  product_2_carbs = products_dictionary["product2"]["carbs"]
  product_2_fats = products_dictionary["product2"]["fats"]

  product_3_kcal = products_dictionary["product3"]["kcal"]
  product_3_proteins = products_dictionary["product3"]["proteins"]
  product_3_carbs = products_dictionary["product3"]["carbs"]
  product_3_fats = products_dictionary["product3"]["fats"]

  product_4_kcal = products_dictionary["product4"]["kcal"]
  product_4_proteins = products_dictionary["product4"]["proteins"]
  product_4_carbs = products_dictionary["product4"]["carbs"]
  product_4_fats = products_dictionary["product4"]["fats"]

  product_5_kcal = products_dictionary["product5"]["kcal"]
  product_5_proteins = products_dictionary["product5"]["proteins"]
  product_5_carbs = products_dictionary["product5"]["carbs"]
  product_5_fats = products_dictionary["product5"]["fats"]

  product_6_kcal = products_dictionary["product6"]["kcal"]
  product_6_proteins = products_dictionary["product6"]["proteins"]
  product_6_carbs = products_dictionary["product6"]["carbs"]
  product_6_fats = products_dictionary["product6"]["fats"]

  x = LpVariable("prod_1_100g", lower_boundary, upper_boundary)
  y = LpVariable("prod_2_100g", lower_boundary, upper_boundary)
  z = LpVariable("prod_3_100g", lower_boundary, upper_boundary)
  w = LpVariable("prod_4_100g", lower_boundary, upper_boundary)
  s = LpVariable("prod_5_100g", lower_boundary, upper_boundary)
  r = LpVariable("prod_6_100g", lower_boundary, upper_boundary)

  optimization_function = product_1_kcal * x + product_2_kcal * y + product_3_kcal * z + product_4_kcal * w + product_5_kcal * s + product_6_kcal * r - diets_dictionary["kcal"] + \
    enhance * product_1_proteins * x + enhance * product_2_proteins * y + enhance * product_3_proteins * z + enhance * product_4_proteins + enhance * product_5_proteins * s +  enhance * product_6_proteins * r - enhance * diets_dictionary["proteins"] + \
    enhance * product_1_carbs * x + enhance * product_2_carbs * y + enhance * product_3_carbs * z + enhance * product_4_carbs + enhance * product_5_carbs * s +  enhance * product_6_carbs * r - enhance * diets_dictionary["carbs"] + \
    enhance * product_1_fats * x + enhance * product_2_fats * y + enhance * product_3_fats * z + enhance * product_4_fats * w + enhance * product_5_fats * s +  enhance * product_6_fats * r  - enhance * diets_dictionary["fats"]

  model += (product_1_kcal * x + product_2_kcal * y + product_3_kcal * z + product_4_kcal * w + product_5_kcal * s + product_6_kcal * r - diets_dictionary["kcal"] + \
    enhance * product_1_proteins * x + enhance * product_2_proteins * y + enhance * product_3_proteins * z + enhance * product_4_proteins + enhance * product_5_proteins * s +  enhance * product_6_proteins * r - enhance * diets_dictionary["proteins"] + \
    enhance * product_1_carbs * x + enhance * product_2_carbs * y + enhance * product_3_carbs * z + enhance * product_4_carbs + enhance * product_5_carbs * s +  enhance * product_6_carbs * r - enhance * diets_dictionary["carbs"] + \
    enhance * product_1_fats * x + enhance * product_2_fats * y + enhance * product_3_fats * z + enhance * product_4_fats * w + enhance * product_5_fats * s +  enhance * product_6_fats * r  - enhance * diets_dictionary["fats"] >= 0)

  model += optimization_function

  solved_model = model.solve()

  print("<<<<SPLITTER>>>>")
  results = {
    "ingridients": [
        {
          "id": products_dictionary["product1"]["id"],
          "weight": value(x)
        },
        {
          "id": products_dictionary["product2"]["id"],
          "weight": value(y)
        },
        {
          "id": products_dictionary["product3"]["id"],
          "weight": value(z)
        },
        {
          "id": products_dictionary["product4"]["id"],
          "weight": value(w)
        },
        {
          "id": products_dictionary["product5"]["id"],
          "weight": value(s)
        },
        {
          "id": products_dictionary["product6"]["id"],
          "weight": value(r)
        }
      ],
    "fit_function": {
        "score": value(model.objective),
        "fit_func_calories_coeff": 1,
        "fit_func_proteins_coeff": enhance,
        "fit_func_carbs_coeff": enhance,
        "fit_func_fats_coeff": enhance
      }
    }

  print(json.dumps(results))

  return results

if __name__ == '__main__':
  calculate_meal_6()
