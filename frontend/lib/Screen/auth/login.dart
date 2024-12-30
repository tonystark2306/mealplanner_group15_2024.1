import 'package:flutter/material.dart';
import 'package:meal_planner_app/Services/auth_service.dart';
import 'package:meal_planner_app/Providers/token_storage.dart';

class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  _SimpleLoginScreenState createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  void handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authApi = AuthApi();
        final response = await authApi.login(
          emailController.text,
          passwordController.text,
        );

        if (response['resultCode'] == '00047') {
          setState(() {
            _isLoading = false;
          });

          String accessToken = response['access_token'] ?? '';
          String refreshToken = response['refresh_token'] ?? '';

          TokenStorage.saveTokens(accessToken, refreshToken);

          if (response['role'] == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/family-group');
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['resultMessage']?['vn'] ?? 'Lỗi không xác định')),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xảy ra lỗi: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo và hình ảnh
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(75),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.network(
                          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADgCAMAAADCMfHtAAABBVBMVEVahm89XEv69t3////u7u7t7e3y8vL7+/v39/dviHb8/Pz09PQvUUH///P9+d9XhG3//+v///f//+8mSzrP1L6ruq+Cl4g3V0b//eN+j34sTz5gdmY0VkT/++XU3Nf59+RJfGVGaVaBn4jw79ggRzWKpZeaqZijr6Ly9Orv79WpsZxTfGaruqh+moaftKduh3M/bFXj599VdWLV2tZni3RCY1HHzcq4x7t0kIC1wrJIdV7J08VkjHdPcl2EoZDf4swsXUdTa1oAPCl0ln20w7aywam+y7np7NyCkYbY3s+iqpahtZ69wKuTq5QAJw7W2cASTzoAMyCQm4h4h38SUDScqaK6wr52whOLAAAY50lEQVR4nNWde1/ivBKAuQhULg1SsFBarFIBLYhlVRRUBC8cdD3r63t2v/9HOb036TVBuez8sb+1QJunM5OZTNI0lrQkk9oxJJWxj+1YkrYPUfbXsvYx+1DOPpROpVI7lCYdRWlcdbu9Xu82Zgp4fOy1ut2rhqJ0cukMRe2kyC9gNS0VQRBbEWGOSmbTytPZ8VH9AogjUQYAxGxR/5Bl9Whs0O8dnz0paedcfwthRhm2YuK5iHD5ifoFoH4v1rpSMn8NYVY5O76WRTkczSWyONg9PlP0C6S2l3BH/e+wfXEORkR0jjrP5e64k8tsJWFqJ52m0je9ARAj7DJclUC+6N2oZ0pvG2EqQynDo6/R2boUwdFQodLbRLiToxrvsahOhQQSxO5/ODRrIIwIV+lK/1u0B4ssPj7ZV/ANuLiEGVvSllDWkax9KJe1DlH2MeOAGhha36k+R4Aot9QQgjbNbkfOPmYdyjhNgwliKUscNeXsY/ahrH2Igu6i9qPF+90q8EzIu/ux2pwdyIIsgZzUEijfgAhitqvBn3sMIGsfgglz1PhxRBb3iBnFxyvKuSblY4gpHwLISX0JvU7sR5jLLFrf7n5ekcX7xbcT4ulQeRwtFdmJRdWjsgHC3Nlg9fqzGQdnuTUTUkN5fXyajMATtU7CHz3CxPrrAsTej7URplsr7kD9RR5109klCEnjYSY5vBU3wKfJ6HZIpXesdtiEEfGQIpPsztn5ej0QFiDep7OELYbzUkdNlux4FNy42ByfJmK/YTQk7TU0P4JUinBs0ZY34YGwALltEEKuFkpARNh43KwCDQGPjVURNjbogbCA88ZKCLOV9eRoOCL+9gtpXyTMva8hy8aW0VvaCv7fNMan0hfbo0FNRheK2eBvIUxlxrdbpEBdwO04Q0wYFA/TmfHGg4RXABhnsOIhVIqxBCqB6JKsxLZNg5oAuZLUmhdBYGfeqeDMu32+aZgAAWe6msIJMMYWlW0FjMXOK8lvGD2dbaOFWqKlcF+tRFXETVOEiqrF9BKEkA4r26xBTUZtG3EJHaaTbXHTBJEiVqzshrynSSWftiuR8ZdRxaxtEFtpinra3l4UFvFJ12JUtPB8nqIWm246poC7hYYYRGgf9eQ8qTWXRJcXEEv5EiTDqxjU7fblokECbikfAk3Cxhb3f0MvYwm4Jyds/T0a1ERukRJeiZtuM6GIV2SEjbtNt5hY7hS/kn8g4VaUDckEPNrpGwbh8d8R6lEBx5YSIwmzjb+pG3VkNLaKU/6rTah0zhBq5+8EVHubFKUTOKtNMrmc3+za+99KCPZNgojVJkNx0y1dWsQnkzB0bNEZbLqdXxDQwSA8/vsChSPnx9GEY3HTrfySjMaGHwYTZv+iEYWvyHsROnwKt1FjZbrrnzVL+Op4uRJOqIQHCvD4rOZzt889EAPv7+o/R2+3oT/4fgHi23PYNBEYKaGrTe4jVDguDWVQKXYewX2hcw/AQfJtvVqUd5slehJ2TW2oGLDaJJdLNqIukBAavNilO/XRfTFRO3xM0OOH72t+tIze50IikbwI7SwaSRgKyUszEUtJwEVVaHBcpdSsc/t7hVr+IUEv4offyhDegF4zoUpxlwuz04tMUJ2Gihr2gntaeOGkSumkzuiEUoKeT9n1IYJmySDMx0MQxbEN5RpbUL0Inxp1aWHIqIQdjfCgxs8SiWqNX5sWwQutASYKKmEIIrim/AmpRlSnIZZp+lSydKgSShO6+B8mviZEcFRIOIQhiKOGL2E2GTnTK05UQl4lnBtWyktlunQmxdeEKDYNFepWGooY8yXEKD7ZhE2HUOhqhOtABO/VBEIYjCg2/AgjvTAGbicJ+jUPW+m4JCx0wjUg9ucmYKJkEgYigh7lQ9gQoy4BdpsmodXTqP+lm7P4WhDl56JFWLAIAxFtJcKE75HJiRaNSjrWiUOYoKX4WhDPmwmPDgMRtQKxFQ+tlRpKdPYFPumEgWX7oUooSOw6EMEjbRMWHcIARAAUfcXJjr3aJJXDmM4GbxahZaXMcSmx92ARRoZ+AAkx4Qvtp8NAxK4xp2iPLdIpjLW/GuEeYqU64cC5XDAiACK46/eOTOlfaA9ukRD2HSOF/DAQEQxSyOgplcUZ2p+rt/FgwLp0WKpBl/NHBCNRfiuPG026SutSbTaV8ktPPMfWJTiqJvx1GL/0PYc4phAdZiJDhXaVn3SC0gktP2TU69Kf0OXyXkQgDt5fFjpYAhbtz8lZH3MQLXehXxcRQn8tgv0kTJiLTNj0H5UtHZqZN8/XVMJTLh6MqNri81ygDxL+Ukw0nmM4S49H5RDCS997ouRgwojihdla1RU6iJVyGuFPDrkcjDgCb2pOEEBnqbI6Pop2SQD/puAi9NWiWMlAhGkcI42BqkVo9TSsRlhGCVl7Yg6IvQkdzqeLcFCWI2xV3g8n9NGiOsJwCNMpEQPQIHxgocw7rxGOefRqZtAAYu2kSgdRuRgLz+HzeeAdtnO3lfprUVTN1CLM4q3tcgibkB8mFp6raYggVu5g8umM87cwNYLnKMK49zdnWWe1CdaEqHytKiz3AFuprsPJpQ+iWFMI+DSpTkJaIT7DZyv5EXq0CHadKgbenDZQCRMHd3BPo+uwM/VcLP/QTWA4ICp08z1QjQDuSn380FeLoGFn3ld4IUkj7NRhHUotNd9vegi5+EuBlE9XYzdoEH5XjtahJ/SDK5vwEyt/Aj2VkL6RHD9kmAnto0NmqlQDKcLVOA7SIkLo64deLYJ3izCLlzrphIm90/+aVpqoSVfadU9chFyd1AUh7fwK0CKODuMuXwRyxiQc461LANf6EJR+mdAn9dl1gS6PNV+jXTpk6kqQCwp0NdHUpBoYJumyf8kexw89iOc/TELcldxiybARWm3HT9U+af1vVzzk+Y5f62m6UG0OXz9ru5p8vo3pkkD7qZo+8TVUXEIk9IMzkzBissL5wS/aabD93yKStbHTiU+7BWFS3s/nJYnnWU04iWEuW7+Uover6t2L1GGgH6rXh7WoZ98qIdXHJXz2u+nFAazDj7K31XR1/n7JcKyrLQwzbRd9GAW/xx9wCVVE6Fd1aicVy2SxxhU6ITwKtdtjVaJ0YcbeXrTa6EuMf2ukj+uml7Ha8s7x4VqpJg4PaFC5WCqDv0gPvHnbf7ALqZDb3fMosNOKO2bMGgL9Ytr2Jq9Nr1URELKOL4Kulpfmootstpy/lFyN2buWnHPnBwfu1pbKH9YXOIZ5ONQ7mvqlxFlGy0rThvu+CYsPd5uwrVRrhh365X2NMIOtQk3GSAdIdz5h+5MWrhtA08eMQcLmmYv2L2Xe6RwcdDqpRXl/wJmq5dkX932pdvkvEKpXs34m6mMLIsLz96ZtVSVhsQtpMM5cu5RRnPSNz1nmsr0oFu0emKYPigfjzwfz9sxOSy5GNcaGEAZHfFtMLYqZZCy3ICKMgcF72bzQS52Hu1G27houCZOpgZCP33QET5QUaOWdMfTI9F0/LY4ldFBL0tPoYipkkYxRxM/9gLrepdIv/6DXkW5QCFqZGu3/aM3dOjIZi+OaUU+W9l2IpU8OQSTVoYk4GquE5GugdnXC0ouEnJFlURulExe6BtWBhld/jh7bRpfD7KOjEWHBI/kJmR/q7dF+Jh8nY2liQjMs0r9QQsaVD5QedQ2qaWoxbKhYGH/oiLOf6A2q7nMwIrkOdV8EKmGHeMEzeDQImyjh1DWiuNE/5i58s09I6PKhjsg30Buhnd5BJPbDuD5eBLVsLIebszmEhpUmUEKmjSQn9C9eazdXD8fTpDjRtchMUTs96PMQ4jKE8cu72IUSUwj5bB0mmkgqJs0RXRUOtW6Wj/vl1m4pGHdDQupp2lg77iCS+6GOKKt80ROjQYQnsA7zu0mkeWXDRl9wCBOltv7tS/QmzfUK1+VXCOOs2IiRPzoCjgzCOZxySy8+rZPG7iQvQA6utSZzAySr3dtnHMSlrFRrwp/YDflMXs3o9eYPUAbNN5BsrqI1jj/ErUcJE73J0gLubATDDgzEZQm5VuyUeD0peKc9hHwd6ev3LrWP+AV2vab0ptHwNeQ2zXnWRlzSSuP5z1iXXIc+hEwLtkfDC7lr/JIp3dHuCTtFMpuDmpkUHn6BcDeGNScTSSghtYtSTwv2M/dII0yEtvYT6SfcM9GvVm99uVTE14Ttf4Gw4xCyEjL61/sZdtDBB0wkJhpNXob7GmHoxCMkHSDwQ3b0FR0eOoR3FHzvF5o+mApRWbhQz2tFFpTavgCa8BDocKkFIhZhc2A3IF9DGvuqEXINopkLoaspjBvDP6peWldACQn8kF3mMUOL8AAifIXdpCprDbgk4dMUr/dOXURX9jKPpQl9Zt0wCI+N2ncOIjxFCLUuMN/HSmccQr10ziO3qnBh1bD4Zf3wK4SwDrkh3AA9YeX2PWW3cDmps3qdADpU2t8Q4ZvZl05tQgYmFOYaIXNDECs0qX5qhIdwRKS7Vme6Zis1CRNOpRTpVYSxTtjFTmgsQvVn7AOsw00RnpttL9RsQqQBwotO6Dd/ESbFlqQRwuOLUgDhyq3U0s5KCHGsdNWEI5PwoBZgpXqJSioTWynnttIgHa7aSkUvIXMFEy6MnoZwqUL1kw/WIXe1fMQnz9pG5mC3BBG+ePvSNmG0KNU80WLPiRY1uGBHlrUtQXhjEArOokTppzfi7xIuxzjQ4iGa/hVtwji3O9mzr7HqzNtaJggtu0RzmsKD9sGUbD2GOt7VbhVyolLMIeFmLXtii2z01CUe459bhK8O4T5SfjjVzJSdJ0jEWACIpA6J6hRuLNO3rIJsBPwmfgMh399DGqt1pohvRkvhWiPMw4UP4QCdGJ+5nyjBIfyMXRFvL2BbqbN01pWKKNoImN8NWjbrK7RGw06RMf7ENfVjhViyShR5NdGHMM6cIK3VusX4B4mZCmOjtIPYwim6cnUZQubPEhVhh9ApMkiISQp65YzZJ8i99Z40ziM1YSgtNC5ilUoIrFS6WqKqP2pat9ghZGqweQnNmVE5wwakx1qb2Tpi2J1D1A+lJfyQaywxM3NuGotQgcr6aEW+8KlXzj6xB8HGaF4aIz84maGttQkJrHSaWmJ2TbQIn6CpGW6MFHMVY9oTtyRc/anHFx7pfZ2s1BSGnFDNkZaYIRXN6wg3MOEp4nR6Gh3P95tYiPT4Q9fREP32AHVD1ibEj/j8v8vMcvsSsodobOjoq0wYrNRN6EwNL0SKrsKYczWXI/dD5niZlQq+hO51CuawQMLJv+maxsJ+zNEzvLowltGhdEa+2gQiHMKEbA1NYQp9A/FnJCJ9ZMw1tlB9dx7QnjTOcuR+KC2IVwwF6tDdrdCKMXM0a++F+qJQ3NVPw9TQFWPVN8nVWv7cugX4OpxliFd9wYSoo7jLh0LZqFhLuychCWp1UtcB8wOXYhXPMw78uTXNjO+HH9rOH9kjQkcMIIzPFihJsfyPgT5YBD07Qxd+GgsX87xrJUfh1N3PLEPI3mmEadLMVDSNxchDHOFqrlS7UDYMNS9dT4q+K4cXdcMU83HXTJzQdHshTIjth1xbJSRYQRtBqMYzVyJaeP4wr3TZVofoqJ/S1XmNM87AsRPXzSl+ur1QM2RiQuaKypGsgjYE3Fr32R2wWKnp8riiwjPmR7PD00aiWizSB3SxWK3OF6/nM/Mzpu9elkqXeXdj4eUe+H6opFMkK9ldhPTEbUhc292nCErPUgbLsfXa2U13Mbm5OapNeWcJbcuzur8a9yPskxLm64RPIxgi963Wzz2uMvvpzrXpauXSDiosKxnirGpnmfrEk/cIv/3WhTuEuFaqZjQG4Q+inS7Bo9WQieeU7KX3YYvC/JhnPPfC/L7Ev3if4av+9PSjOuEuKaE0NgnT36bDODf1NpguzT+nkk+bOGnQbXpHycJc8r0hXMsKuLgRn0+TPdll6fDCavnc56RMzy8slJrlflxieHOVPsuyeYmL7058Vg6rsX7gr3GuZX0Z0w/zNfvZNaK9IOVeiA61lTW+0Z2uJoantfqD7oYPh4PP0yv/hcN0oh7QfK5FWC9l/tiECslmkODaVo3/edsB5RmBTnQ6zRNVOgdqcBT870Sn5v/0CUyI6Ye884Ql0bbBsqMk/xNLreBBIR1RnKJLNW+o9xDi6ZCf7ulPyRI86ewmrHofANZEDXDhGCGAyiBIg6px2JMjeH7I3CdJn1b3EAadW+oViJ8C1gEng5CmM2UyQqmRI91xwBBga6g6DQhzcWbawKxBIfLLm27DLS4T+SFbp+A9FQjMFLxHE6qDhXL4wNdHgdVWUGJg3jYyQuY3Rbzzh0loP3VQDbOpWf2EaMlQtTEN7GPchFhWyjVyxLu3eAgvfLMrU/LTm4hNP2AFJl75qFaTEeblDPkOPIaI9oru0m34haR4+QBr6qI4r0gRClTl4RdJtJCG6A48WLsokRLGWb5+U4ja3USgm91puAeahA0SP7xEd1HC2wnLTQhNswffyvpN2FNBdIlevB76Z9qeNisEOuSO7Z2wCHYzW4Ywrg7y6zfzPZ8kTRDozqQ7ZXH0hxJi+CHj7GZGsCOdSWjPwezhEMa1URJfex0uqoWiQJtSKhYTjcqrmonjrxsh0SHXc3akI9hV0BAwJtKhLizPMPzlYL/b/TX59WvyctO6vohzXB5Te6Yo+H4o/VhqZ0iTsExOaEieYxijisEwnPvx/GiZ7mDrUM1nltvdUxfZJnSV9Vcs0NRUpB9Kvrt7ZqJ3aHURFreVkP1f0pcwepddQ2xCelOEUX4oXfkTRu+UrIuz3U9pSwkdL/QQ4nnixnRoR9IIK505KnS/SSdqx3JdBhNHh9HJ5PcJW6viEfJTdMdysl3nVZFtQvNB0TUJRBgeLfgf6K7zRG8O0OXXhvzQIdwbhRBy/4a+SSfi7Q+aQBG/vU7C+NRelFS4DEkXPtxvfyB7g0cMetwiIQRXMVYhXNkco9CTEO/gfifDCbPRL1G/mxvlCWG4TjfU5soK+r2lS/1gI+XjuQjC5Bhj0+uJoEqpHFoZW4FIpx3hQKAL7TAVtpNRhBhvQwKxVmM+/iTPnb8qUr2izJ/7IQNK5j/JaEKcN1qNGIYhG1d8j7Da6CSkH2V5BYMQayZKXrv+sGRWSXoJl3yznLxpGD/J+75ZzuftgCmcxe1bqEVWWmR83g4I56WmZvHe8Lh9WpSGPm94DHjjMdaa021DlP7N4L6lE/dNq9uFmJ+SvGkVd2dh/ynSzchDg+htuZi1Rflwa/qbGeEbj3HfWr01hip9rurN41sSNLhdipyQih5lbI0W+Tje2+MtMT9PYdZPN++LLJfyJUjaq010bjsvNd/imaIWOIAqYtiIey3C6C9z9hAEZt7W5ynqCXPRIsGz4ysQVjrT5wq9BFGEOzvJJ8zHLzeqRKlihnqIYAeTMJ1si1tvqNKxlcssQah+jjn5vbnuxgFckjBZwdNi7HDjgMsS4q4C30zol+7VgPBVwqTfFuk+sok0XNJew41LGBBNNGnjIcqH6wbk9PeMp8IJrNUm6XQua0nOPmb8naxgZjfr7VFZNUxozYsgCMnakloNQK9RZQJfHeKSdRoqLz1l0kaxKYQgFVDFsAmtI+MBphbXB3g5zsCuFEiARagmcLk+XnqzLjvlHlJW2elbCNXsJvcuYqlxPaFf2t+hrLLTdxEmsxUsLYJ1EEq1JOXq8L+BMJls4LzGLxZbOV+eHyedTOY7CZMK1nKUVcdFZqqteFoNoRr8ZYwC1UoR2ZkxObEUYVA8hKdtGlhriVeHyByaqw7T0ORLCAGy2gRLMqkzDG9cmRZnu+ksYYv9Ztdy3tuThW7P8BajU11J6GfYP1R6x6smU3K+BBhjC4PQOkSpBtIdRXvj4bfzsf+0FCcHgQh9CCAn9SX0OjFCmEz+6ImRhvrdWpQGV0koCoYT4laiAgmT1DAWaaqH38nHSb/3kviEUTqMJlS/dBaZjH+fFvN8y2jeOgnV+P8Ylal+03iRnw2sVc3rJcxlFq0Ixu9Iw/PS7sK+5noJ06kcNX4Mj45fNtS8JP9JO9dchpA0HsKE2o8W7yCszzn8Ch7LfNQW2t2FCC3JOoQR8dBel5Gxaxv2Wg24BGIdouxjxoFkRjkOez/68oislN9vZJNo0+x2QKUYZ72MHwHmGN9RsGMnzl1MV/rBDrmkoTLM3W/7qj7ltPQqxoeBhDs5qvEujwI0Sa5Flpf42g+HxpcQcrXVE6qH0pQy7AUwEmqRl7h+Rcmk0QtsnFD9iuoHN70B8LFXfC2ynBSvd9OZXNp7gY0T7qj/qv8dti/OgVuXeFrkpdnD7z8KlQ24wMYJrQZklbPja1mUSbSo7XVy+e9ZQ1tRsZOKuMDGCfWTKcNWbDRytBmoRbVXUeVj909DIbnAxgmTOSqZTStPZ8dH9QsgjmT5En6ckmXz+TzHSVJ8Wv/3uLJIO+f6awi1hEcNIqp0FOXqqtvtDaARoywPdvdblauG0slQGYrKRQTcrxD+H59caHagbZ9EAAAAAElFTkSuQmCC', // Thêm logo của bạn vào đây
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Tiêu đề
                    Text(
                      "Đi chợ tiện lợi",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Đăng nhập để tiếp tục",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form đăng nhập
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Email field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              hintText: "Nhập email của bạn",
                              prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.green[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập email";
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return "Email không hợp lệ";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: "Mật khẩu",
                              hintText: "Nhập mật khẩu của bạn",
                              prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.green[700],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.green[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập mật khẩu";
                              } else if (value.length < 6) {
                                return "Mật khẩu phải có ít nhất 6 ký tự";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Quên mật khẩu
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forget-password');
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nút đăng nhập
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "ĐĂNG NHẬP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Đăng ký
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có tài khoản? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            "Đăng ký ngay",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}